package ibbt.sumo.sampleevaluators.distributed;
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
** Revision: $Id$
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.util.Util;

import java.util.Date;
import java.util.LinkedList;
import java.util.Properties;
/**
 * This class represents the typical distributed Job.
 */
public class Job {
	private static int JOB_ID = 1;
	private int id = -1;
	private String executable;
	private String arguments;
	private String stdin;
	private String stdout;
	private String stderr;
	private LinkedList<String> inputSandbox = new LinkedList<String>();
	private LinkedList<String> outputSandbox = new LinkedList<String>();
	private Properties properties = new Properties();
	private long submittedOn = -1;
	private long completedOn = -1;
	private long createdOn = -1;
	
	
	public Job(){
		id = JOB_ID;
		++JOB_ID;
		this.createdOn = System.currentTimeMillis();
	}
	
	public Job(String exe, String args, String stdout){
		id = JOB_ID;
		++JOB_ID;
		this.executable = exe;
		this.arguments = args;
		this.stdout = stdout;
		this.createdOn = System.currentTimeMillis();
	}
	
	public int getId(){
		return id;
	}
	
	public String getArguments() {
		return arguments;
	}

	public void setArguments(String arguments) {
		this.arguments = arguments;
	}

	public String getExecutable() {
		return executable;
	}

	public void setExecutable(String executable) {
		this.executable = executable;
	}

	public LinkedList<String> getInputSandbox() {
		return inputSandbox;
	}

	public void setInputSandbox(LinkedList<String> inputSandbox) {
		this.inputSandbox = inputSandbox;
	}
	
	public void addToInputSandbox(String s){
		this.inputSandbox.add(s);
	}

	public void addToOutputSandbox(String s){
		this.outputSandbox.add(s);
	}
	
	public String getStderr() {
		return stderr;
	}

	public void setStderr(String stderr) {
		this.stderr = stderr;
	}

	public String getStdin() {
		return stdin;
	}

	public void setStdin(String stdin) {
		this.stdin = stdin;
	}

	public String getStdout() {
		return stdout;
	}

	public void setStdout(String stdout) {
		this.stdout = stdout;
	}

	public LinkedList<String> getOutputSandbox() {
		return outputSandbox;
	}

	public void setOutputSandbox(LinkedList<String> outputSandbox) {
		this.outputSandbox = outputSandbox;
	}
	
	public Properties getProperties(){
		return properties;
	}

	public long getCompletedOn() {
		return completedOn;
	}

	public void setCompletedOn(long completedOn) {
		this.completedOn = completedOn;
	}

	public long getSubmittedOn() {
		return submittedOn;
	}

	public void setSubmittedOn(long submittedOn) {
		this.submittedOn = submittedOn;
	}
	
	public long getCreatedOn(){
		return this.createdOn;
	}
	
	public String toString(){
		String inputbox = "";		
		if(inputSandbox != null && inputSandbox.size() > 2){
			for(String s : inputSandbox){
				inputbox += s + ", ";
			}	
			inputbox = inputbox.substring(0,inputbox.length()-2);
		}
		
		String outputbox = "";
		if(outputSandbox != null && outputSandbox.size() > 2){
			for(String s : outputSandbox){
				outputbox += s + ", ";
			}
			outputbox = outputbox.substring(0,outputbox.length()-2);
		}
		
		String s = "Job id=" + id
				+ "\n  - Executable: " + executable
				+ "\n  - Arguments: " + arguments
				+ "\n  - StdIn: " + stdin
				+ "\n  - StdOut: " + stdout
				+ "\n  - StdErr: " + stderr
				+ "\n  - Input Sandbox: " + inputbox
				+ "\n  - Output Sandbox: " + outputbox
				+ "\n  - Additional properties:\n" + Util.toString(properties)
				+ "\n  - Created on: " + new Date(createdOn).toString();
		
		if(submittedOn > 0){
				s += "\n  - Submitted on: " + new Date(submittedOn).toString();
		}

		if(completedOn > 0){
				s += "\n  - Completed on: " + new Date(completedOn).toString();
		}
		
		return s;
	}
}
