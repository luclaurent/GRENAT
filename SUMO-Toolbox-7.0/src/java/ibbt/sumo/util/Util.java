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
** Revision: $Id: Util.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.sampleevaluators.SamplePoint;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.lang.reflect.Array;
import java.security.MessageDigest;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Properties;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;
/**
 * Misc. helper functions
 */
public class Util {
	private static Logger logger = Logger.getLogger("ibbt.sumo.util.Util");

//	-------------------------------------------------------------------------------------
	/**
	 * Is there a display hooked up
	 */
	public static boolean isHeadless(){
		return java.awt.GraphicsEnvironment.isHeadless();
	}
//	-------------------------------------------------------------------------------------
	
	/**
	 * A utility function for reading the input parameters passed to a java simulator
	 * on the command line
	 * @param in the input stream to use
	 * @param inDim the number of inputs
	 * @param outDim the output dimension
	 * @return the samplepoints read
	 */
	public static SamplePoint[] readSimulatorInput(InputStream in, int inDim, int outDim){
		BufferedReader r = new BufferedReader(new InputStreamReader(new BufferedInputStream(in)));

		SamplePoint[] points = null;
		
		try{
			//how many samples will be passed
			int numSamples = Integer.parseInt(r.readLine());
			points = new SamplePoint[numSamples];
			
			//for every sample
			for(int i = 0; i < numSamples ; ++i){
				//read the inputs
				double[] inputs = new double[inDim];
				int ctr = 0;
				String line = r.readLine();
				while(ctr < inDim && line != null){
					inputs[ctr] = Double.parseDouble(line);
					++ctr;
					if(ctr < inDim) line = r.readLine();
				}
				
				points[i] = new SamplePoint(inputs,new double[outDim]);
			}
			
		}catch (Exception e) {
			logger.log(Level.SEVERE,"Error reading samplepoints from standard input: " + e.getMessage(),e);
			points = null;
		}
		
		return points;
	}

//	-------------------------------------------------------------------------------------
	public static boolean isValidIdentifier(String name){
		String regex = "[A-Za-z_][A-Za-z_0-9]*";
		return name.matches(regex);
	}
//	-------------------------------------------------------------------------------------
	 public static byte[] getBytesFromFile(File file) throws IOException {
	        InputStream is = new FileInputStream(file);
	    
	        // Get the size of the file
	        long length = file.length();
	    
	        if (length > Integer.MAX_VALUE) {
	            // File is too large
	        }
	    
	        // Create the byte array to hold the data
	        byte[] bytes = new byte[(int)length];
	    
	        // Read in the bytes
	        int offset = 0;
	        int numRead = 0;
	        while (offset < bytes.length
	               && (numRead=is.read(bytes, offset, bytes.length-offset)) >= 0) {
	            offset += numRead;
	        }
	    
	        // Ensure all the bytes have been read in
	        if (offset < bytes.length) {
	            throw new IOException("Could not completely read file "+file.getName());
	        }
	    
	        // Close the input stream and return bytes
	        is.close();
	        return bytes;
	    }
//	-------------------------------------------------------------------------------------
	/**
	 * 
	 * @param name
	 * @return
	 */
	public static String getAbsolutePath( String name, String path ) {
		if ( name == null || name.trim().length() == 0 )
			return name;
		
		name = Util.cleanFileSeparators(name);
		
		if ( new File( name ).isAbsolute() )
			return name;
		
		return path + File.separator + name;		
	}
//	-------------------------------------------------------------------------------------	
	/**
	 * Create a unique outputdirectory
	 * @return homedir
	 */
	public static String generateOutputDirectoryName( String outputdir, String run_name, int run_nr, int numRuns) 
	{
		String od = "";

		SimpleDateFormat dateformat = new SimpleDateFormat("yyyy.MM.dd_HH-mm-ss");
		
		od = outputdir + File.separator + run_name;
		
		if(numRuns > 1){
			if( run_nr < 10){
				od += "_run0" + run_nr;
			}else{
				od += "_run" + run_nr;
			}
		}
	
		od += "_" + dateformat.format(new Date());
		
		return makeFilenameUnique(od);
	}	
//	-------------------------------------------------------------------------------------

	public static String makeFilenameUnique(String name){
		String suffix = "";
		int ctr = 1;
		
		while(new File(name + suffix).exists()){
			if(ctr < 10){
				suffix = "_0" + Integer.toString(ctr);
			}else{
				suffix = "_" + Integer.toString(ctr);
			}
			++ctr;
		}			
			
		return name + suffix;
	}
	
//	-------------------------------------------------------------------------------------
	/**
	 * getPlatform
	 * @param 
	 * @return enum platform: defining the platform
	 */		
	public static SystemPlatform getPlatform() {
		return resolvePlatformName(System.getProperty("os.name"));
	}
	public static SystemPlatform resolvePlatformName( String systemName) {
		
		systemName = systemName.toUpperCase();
		
		// Windows
		if ( systemName.contains( "WINDOWS") || systemName.contains( "WIN") )
			if ( systemName.contains( "VISTA") )
				return SystemPlatform.VISTA;
			else if ( systemName.contains( "XP") )
				return SystemPlatform.XP;
			else
				return SystemPlatform.WIN;
		// Macintosh
		else if ( systemName.contains( "MAC") || systemName.contains( "APPLE") || systemName.contains( "DARWIN") )
			if ( systemName.contains( "LEOPARD") ||  systemName.contains( "OSX") )
				return SystemPlatform.MACOSX;
			else
				return SystemPlatform.MAC;
		
		// Matlab (special platform)
		else if ( systemName.contains( "MATLAB") )
			return SystemPlatform.MATLAB;
		// Java (special platform)
		else if ( systemName.contains( "JAVA") )
			return SystemPlatform.JAVA;
		// Unix
		else // assume some unix variant
			if ( systemName.contains( "LINUX") )
				return SystemPlatform.LINUX;
			else if ( systemName.contains( "BSD") )
				return SystemPlatform.BSD;
			else
				return SystemPlatform.UNIX; // AIX, HP-UX, Solaris, ...
	}
//	-------------------------------------------------------------------------------------
	/**
	 * getArchitecture
	 * @param 
	 * @return enum arch: defining the architecture
	 */	
	public static SystemArchitecture getArchitecture() {
		SystemArchitecture arch = resolveArchitectureName(System.getProperty("os.arch"));
		if( arch == SystemArchitecture.ANY )
			arch = SystemArchitecture.X86; // Default to x86
		return arch;
	}
	
	public static SystemArchitecture resolveArchitectureName(String archName){
		archName = archName.toUpperCase();
		
		if ( archName.contains( "AMD64" ) || archName.contains( "X86_64" ) )
			return SystemArchitecture.X86_64;	
		else if ( archName.contains( "X86") ||
				 archName.contains( "I386") ||
				 archName.contains( "I486") ||
				 archName.contains( "I586") ||
				 archName.contains( "I686") )
			return SystemArchitecture.X86;
		else if ( archName.contains( "POWERPC") || archName.contains( "PPC"))
			return SystemArchitecture.POWERPC;
		else if ( archName.contains( "SPARC") )
			return SystemArchitecture.SPARC;		
		else
			return SystemArchitecture.ANY; // Don't know, can be anything
	}
//	-------------------------------------------------------------------------------------
	
	/**
	 * Set all file separators to the one for the current platform
	 * @param path
	 * @return
	 */
	public static String cleanFileSeparators(String path){
		String res = path.replace( '/', File.separatorChar );
		res = res.replace( '\\', File.separatorChar );
		return res.trim();
	}
	
	private static String getHexString(byte[] data) {
        StringBuffer buf = new StringBuffer();
        for (int i = 0; i < data.length; i++) {
        	int halfbyte = (data[i] >>> 4) & 0x0F;
        	int halfs = 0;
        	do {
	        	if ((0 <= halfbyte) && (halfbyte <= 9))
	                buf.append((char) ('0' + halfbyte));
	            else
	            	buf.append((char) ('a' + (halfbyte - 10)));
	        	halfbyte = data[i] & 0x0F;
        	} while(halfs++ < 1);
        }
        return buf.toString();
    }
	
	public static String genHash(String text){ 
		try{
			MessageDigest md = MessageDigest.getInstance("MD5");
			byte[] md5hash = new byte[32];
			md.update(text.getBytes("iso-8859-1"), 0, text.length());
			md5hash = md.digest();
			return getHexString(md5hash);
		}catch(Exception e){
			logger.warning(e.getMessage());
			return null;
		}
	}
	
	public static String getFileContent(String s){
		String content = "";
		String line = null;
		try{
			File f = new File(s);
			BufferedReader reader = new BufferedReader(new FileReader(f));
			line = reader.readLine();
			while(line != null){
				content += line + "\n";
				line = reader.readLine();
			}
			return content;
		}catch (Exception e) {
			logger.log(Level.SEVERE,"Error while reading file content",e);
			return null;
		}
	}
	
	public static String getRandomPrefix(){
		//TODO: not foolproof, use internal Java method instead
		Random rand = new Random();
		//A string of 6 random numbers between 0 and 10
		String s = "";
		for(int i=1;i<=6;++i){
			s += rand.nextInt(10);
		}
		return s;
	}
	
	public static int contains(String[] array, String s){
		for(int i = 0; i < array.length ; ++i){
			if(array[i].equals(s)) return i;
		}
		
		return -1;
	}
	
	public static String join(Collection<String> s, String delimiter) {
        StringBuffer buffer = new StringBuffer();
        Iterator iter = s.iterator();
        while (iter.hasNext()) {
            buffer.append(iter.next());
            if (iter.hasNext()) {
                buffer.append(delimiter);
            }
        }
        return buffer.toString();
    }

	public static String join(String[] str, String delimiter) {
        StringBuffer buffer = new StringBuffer();
        for(int i=0;i<str.length;++i){
            buffer.append(str[i]);
            if (i < str.length-1) {
                buffer.append(delimiter);
            }
        }
        return buffer.toString();
    }

	public static String doubleArrayToString( double[] list ) {
		if ( list == null || list.length == 0 ){
			return "";			
		}
		//Enforce scientific notation with '.' instead of ','
		DecimalFormat formatter = new DecimalFormat();
		formatter.applyLocalizedPattern("0.00000000E00");

        StringBuffer buffer = new StringBuffer();

        buffer.append(formatter.format(new Double(list[0])));
		for ( int i=1;i<list.length;i++ ){
			buffer.append(' ');
			buffer.append(formatter.format(new Double(list[i])));
		}
		
		return buffer.toString();
	}

	public static String toString(Properties prop){
		String res = "";
		Enumeration en = prop.keys();
		Object tmp;
		while(en.hasMoreElements()){
			tmp = en.nextElement();
			res += tmp.toString() + " = " + prop.getProperty(tmp.toString()) + "\n";
		}
		return res.trim();
	}
	
	public static String getWorkingDir(){
		return System.getProperty("user.dir");
	}

	static public String getDateTime() {
		DateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy_HH-mm-ss");
		Date date = new Date();
		return dateFormat.format(date);
	}
	
	static public void copyFile(String in, String out) throws IOException {
		FileInputStream fis  = new FileInputStream(in);
		FileOutputStream fos = new FileOutputStream(out);
		byte[] buf = new byte[1024];
		int i = 0;
		while((i=fis.read(buf))!=-1) {
			fos.write(buf, 0, i);
		}
		fis.close();
		fos.close();
	}
	
	public static String getFileName(String path){

		String fileName = null;
		String separator = File.separator;

		int pos = path.lastIndexOf(separator);
		fileName =path.substring(pos+1);
		
		return fileName;
	}
	
	// If targetLocation does not exist, it will be created.
	public static void copyDirectory(File sourceLocation , File targetLocation) throws IOException {
		
		if (sourceLocation.isDirectory()) {
			if (!targetLocation.exists()) {
				targetLocation.mkdir();
			}
			
			String[] children = sourceLocation.list();
			for (int i=0; i<children.length; i++) {
				copyDirectory(new File(sourceLocation, children[i]),
						new File(targetLocation, children[i]));
			}
		} else {
			
			InputStream in = new FileInputStream(sourceLocation);
			OutputStream out = new FileOutputStream(targetLocation);
			
			// Copy the bits from instream to outstream
			byte[] buf = new byte[1024];
			int len;
			while ((len = in.read(buf)) > 0) {
				out.write(buf, 0, len);
			}
			in.close();
			out.close();
		}
	}
	
	public static InputStream PropertiesToInputStream(Properties p) {
		ByteArrayOutputStream b = null;
		
		try {
			//create an output stream
			b = new ByteArrayOutputStream();
			//store thr poperties object to this output stream
			p.store(b, "");
			//attach an input stream and return it
			return new ByteArrayInputStream(b.toByteArray());
		} catch (Exception e) {
			logger.log(Level.SEVERE,e.getMessage(),e);
			return null;
		} finally {
			try {
				b.close();
			} catch (Exception ex) {
				logger.log(Level.SEVERE,ex.getMessage(),ex);
			}
		}
	}

	//	-------------------------------------------------------------------------------------
	/**
	 * A utility method to close any stream
	 */
	public static void close(Closeable c){
		if (c != null) {
	      try {
	        c.close();
	      } catch (IOException e) {
	        logger.log(Level.WARNING,"Failed to close stream " + c.toString() + ": " + e.getMessage(),e);
	      }
	    }else{
	    	//ignore null
	    }
	}
	
	//	-------------------------------------------------------------------------------------	
	 public static String arrayToString(Object array) {
	    if (array == null) {
	      return "[NULL]";
	    } else {
	      Object obj = null;
	      if (array instanceof Hashtable) {
	        array = ((Hashtable)array).entrySet().toArray();
	      } else if (array instanceof HashSet) {
	        array = ((HashSet)array).toArray();
	      } else if (array instanceof Collection) {
	        array = ((Collection)array).toArray();
	      }
	      int length = Array.getLength(array);
	      int lastItem = length - 1;
	      StringBuffer sb = new StringBuffer("[");
	      for (int i = 0; i < length; i++) {
	        obj = Array.get(array, i);
	        if (obj != null) {
	          sb.append(obj);
	        } else {
	          sb.append("[NULL]");
	        }
	        if (i < lastItem) {
	          sb.append(", ");
	        }
	      }
	      sb.append("]");
	      return sb.toString();
	    }
	 }



public static void main(String[] args){
	System.out.println(genHash(""));
}

}
