package ibbt.sumo.util;
/**----------------------------------------------------------------------------------------
** This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
**
** This program is free software; you can redistribute it and/or modify it under
** the terms of the GNU Affero General Public License version 3 as published by the
** Free Software Foundation.
** 
** This program is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
** PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
** 
** You should have received a copy of the GNU Affero General Public License along
** with this program; if not, see http://www.gnu.org/licenses or write to the Free
** Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301 USA, or download the license from the following URL:
** 
** http://www.sumo.intec.ugent.be
** 
** In accordance with Section 7(b) of the GNU Affero General Public License, these
** Appropriate Legal Notices must retain the display of the "SUMO Toolbox" text and
** homepage.  In addition, when mentioning the program in written work, reference
** must be made to the corresponding publication.
** 
** You can be released from these requirements by purchasing a commercial license.
** Buying such a license is in most cases mandatory as soon as you develop
** commercial activities involving the SUMO Toolbox software. Commercial activities
** include: consultancy services or using the SUMO Toolbox in commercial projects 
** (standalone, on a server, through a webservice or other remote access technology).
** 
** For more information, please contact SUMO lab at
** 
**             sumo@intec.ugent.be - www.sumo.intec.ugent.be
**
** Revision: $Id: SSHWrapper.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.trilead.ssh2.Connection;
import com.trilead.ssh2.SCPClient;
import com.trilead.ssh2.Session;
import com.trilead.ssh2.StreamGobbler;

/**
 * A wrapper class for all kinds of shell commands that need to be executed on
 * a remote host over ssh
 */
public class SSHWrapper {
	private static Logger logger = Logger.getLogger("ibbt.sumo.util.SSHWrapper");

	private String identityFile = null;
	private String idFilePassword = null;
	private Connection connection = null;
	private String username = null;
	private String host = null;
	private int port = -1;
	
	public SSHWrapper(String identityFile, String identityFilePwd, String username, String host, int port) throws IOException {
		this.identityFile = identityFile;
		this.idFilePassword = identityFilePwd;
		this.username = username;
		this.host = host;
		this.port = port;
	}

	/**
	 * Authenticate to the server
	 */
	public void connect() throws IOException {

		connection = new Connection(this.host,this.port);
		
		int maxTries = 3;
		
		int i = 0;
		while(i < maxTries){

			connection.connect();
			boolean isAuthenticated = connection.authenticateWithPublicKey(this.username,new File(identityFile),idFilePassword);
			
			if(!isAuthenticated || !connection.isAuthenticationComplete()){
				logger.severe("FAILED to establish session to " + this.username + "@" + this.host + ":" + this.port + ", try " + i + " of " + maxTries);
				connection.close();
				
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
					logger.log(Level.WARNING,e.getMessage(),e);
				}
				
			}else{
				logger.fine("SSH session to " + this.username + "@" + this.host + ":" + this.port + " established");
				break;
			}

		}
	}
	
	public String getHost(){
		return this.host;
	}
	
	public int getPort(){
		return port;
	}
	
	public String getUserName(){
		return this.username;
	}
	
	public boolean isConnected(){
		return connection.isAuthenticationComplete();
	}
	
	//TODO relies on a native call of scp, needs to be changed
	public void copyDirectory(String localDir, String remoteDir) throws Exception{
		logger.fine("Calling native scp process to copy localhost:" + localDir + " to " + this.username + "@" + host + ":" + remoteDir + "/");
		String[] cmd = 
			new String[]{"scp","-r","-p", localDir, this.username + "@" + this.host + ":" + remoteDir};
		Process p = Runtime.getRuntime().exec(cmd);
        InputStream is = p.getInputStream();
        InputStreamReader isr = new InputStreamReader(is);
        BufferedReader br = new BufferedReader(isr);
        
        logger.finest("--- Logging scp process output");
        //Log output stream
        String line = null;
        while ((line = br.readLine()) != null) {
            logger.finest(line);
        }
        logger.finest("--- End of scp process output");
        logger.fine("External scp process done");
        
		//Remember to always explicitly close all streams before destroying the process!
		//This is important!!
		Util.close(is);
		p.destroy();
	}
	
	public int getFileSize(String file)throws Exception {
		String cmd = "du -b " + file + " | awk '{print $1}'";
		String res = remoteExec(cmd);
		logger.finest("Got size '" + res + "' for file " + file);
		if(res.length() < 1){
			return -1;
		}else{
			return new Integer(res).intValue();
		}
	}
	
	public void createFile(String path, String content) throws Exception {
		String cmd = "echo \"" + content +"\" > " + path;
		remoteExec(cmd);
		logger.fine("Created file '" + path + "'");
		logger.finest("File content is\n---\n" + content + "\n---");
	}
	
	public boolean removeFile(String file) throws Exception {
		String rmCommand = "rm -v " + file;
		String res = remoteExec(rmCommand);
		if (res.startsWith("removed")) {
			logger.fine("Removed file " + file);
			return true;
		} else {
			logger.warning("Warning: failed to remove file " + file	+ " output is " + res);
			return false;
		}
	}
	
	public void removeDir(String directory) throws Exception {
		String cmd = "rm -rfv " + directory;
		String res = remoteExec(cmd);
		
		logger.fine("Removed directory, command output is:\n\n" + res);
	}
	
	public void makeDir(String directory) throws Exception {
		String cmd = "mkdir -p " + directory;
		String res = remoteExec(cmd);
		
		if (res.length() > 0) {
			logger.warning("Warning: Error during creating remote directory "
					+ directory + ", output is " + res);
		}
	}
	
	public String remoteExec(String command) throws Exception {
		return remoteExec(command,null);
	}
	
	public String remoteExec(String command, String ignorePrefix) throws Exception {
		LinkedList<String> result = remoteExecAsList(command,ignorePrefix);
		String r = "";
		
		for(String s : result){
			r += s + "\n";
		}
		
		return r.trim();
	}

	public LinkedList<String> remoteExecAsList(String command) throws Exception {
		return remoteExecAsList(command,null);
	}
	
	private Session getSession() throws IOException {
		return connection.openSession();
	}
	
	public LinkedList<String> remoteExecAsList(String command, String ignorePrefix) throws IOException {
		LinkedList<String> result = new LinkedList<String>();
		Session sess = null;
		
		try{
			sess = getSession();
			
			logger.finer("Going to execute command '" + command + "'");
			
			sess.execCommand(command);
			
			InputStream stdout = new StreamGobbler(sess.getStdout());
			InputStream stderr = new StreamGobbler(sess.getStderr());
	
			BufferedReader stdoutReader = new BufferedReader(new InputStreamReader(stdout));
			BufferedReader stderrReader = new BufferedReader(new InputStreamReader(stderr));
	
			//Read std::out
			String line = "";
			while (true) {
				line = stdoutReader.readLine();
				
				if (line != null && (ignorePrefix == null || !line.startsWith(ignorePrefix))){
					result.add(line);
					logger.finest("Added line '" + line + "'");
				}else{
					break;
				}
			}
			
			//Read std::err
			line = "";
			while (true) {
				line = stderrReader.readLine();
				if (line != null){
					logger.finest("Ignoring std::err line '" + line + "'");
				}else{
					break;
				}
			}

		}finally{
			//Always close the session
			sess.close();
			logger.finer("Session ExitCode: " + sess.getExitStatus());
		}
		
		return result;

	}
	
	public void scpFrom(String remoteFile, String localFile) throws Exception {
		SCPClient scpClient = new SCPClient(connection);
		
		File f = new File(localFile);
		BufferedOutputStream buf = new BufferedOutputStream(new FileOutputStream(f));
		
		scpClient.get(remoteFile, buf);

		buf.close();
	}
	
	public void scpTo(String localFile,String remoteFile) throws Exception {
		SCPClient scpClient = new SCPClient(connection);
		
		File lf = new File(localFile);
		File rf = new File(remoteFile); 
		
		String remoteDir = rf.getParent();
		if(remoteDir == null){
			remoteDir = "";
		}
		
		scpClient.put(Util.getBytesFromFile(lf),rf.getName(),remoteDir);
	}
	
	public void close(){
		connection.close();
	}
	
	public static void main(String[] arg) {
		String user = "dgorisse";
		String host = "submit.calcua.ua.ac.be";
		String khFile = System.getProperty("user.home") + "/.ssh/known_hosts";
		String idFile = System.getProperty("user.home") + "/.ssh/id_dsa";
		
		SSHWrapper ssh = null;
		
		try {

			System.out.println("Starting.......");
			
			ssh = new SSHWrapper(idFile,khFile, user, host, 22);

			System.out.println("Connecting.......");
			
			ssh.connect();
			
			System.out.println("Connected....");
			
			String res = ssh.remoteExec("uname -a");
			System.out.println("Result is: " + res);
			res = ssh.remoteExec("export SGE_ROOT=/grid;/grid/bin/lx24-amd64/qstat -g c");
			System.out.println("Result is: " + res);
			
			ssh.scpTo("/home/dgorissen/test.txt", "test-sent.txt");
			ssh.remoteExec("cp test.txt test-sent.txt");
			ssh.remoteExec("echo 'this was added' >> test-sent.txt");
			ssh.scpFrom("test-sent.txt", "/home/dgorissen/test-sent.txt");
		} catch (Exception e) {
			System.out.println(e);
			e.printStackTrace();
		} finally {
			ssh.close();
		}
	}
}
