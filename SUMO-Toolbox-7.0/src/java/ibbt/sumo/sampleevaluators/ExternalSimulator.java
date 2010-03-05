package ibbt.sumo.sampleevaluators;
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

import ibbt.sumo.util.ProcessInputStream;
import ibbt.sumo.util.Util;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.Properties;
import java.util.Scanner;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/*
From the Process Javadoc:
 
The methods that create processes may not work well for special processes on 
certain native platforms, such as native windowing processes, daemon processes,
Win16/DOS processes on Microsoft Windows, or shell scripts. The created subprocess
does not have its own terminal or console. All its standard io (i.e. stdin, stdout,
stderr) operations will be redirected to the parent process through three
streams (getOutputStream(), getInputStream(), getErrorStream()). The parent
process uses these streams to feed input to and get output from the subprocess.
Because some native platforms only provide limited buffer size for standard 
input and output streams, failure to promptly write the input stream or 
read the output stream of the subprocess may cause the subprocess 
to block, and even deadlock.
*/

public class ExternalSimulator implements Simulator {
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.ExternalSimulator");
	
	private File fExecutable;
	private Runtime fRuntime;
	private long fTimeout;
	private String options = "";
	private boolean fBatchMode = false;
	
	private void init( File file, long timeout )
	{
		assert( file != null );
		fExecutable = file;
		fRuntime = Runtime.getRuntime();
		fTimeout = timeout;
	}
	
	public ExternalSimulator(File file ) {
		init( file, -1 );
	}

	public ExternalSimulator(File file, long timeout ) {
		init( file, timeout );
	}

	public void configure(Properties p){
		Set<Object> keys = p.keySet();
		
		options = "";
		
		for(Object key : keys){
			options += "-" + key + "=" + p.getProperty(key.toString()) + " ";
		}
		
		options = options.trim();
		
		logger.fine("External simulator configured with the following options: '" + options + "'");
	}
	
	// set batch mode
	public void setBatchMode(boolean b) {
		fBatchMode = b;
	}
	
	public void simulateBatch(EvaluationUnitBatch batch) throws SampleEvaluatorException {
		
		// create the executable string
		String command = (fExecutable + " " + options).trim();
		
		// get samples to evaluate
		SamplePoint[] samples = batch.getSamples();
		
		// make sure we evaluate at least one sample
		if (samples.length == 0) return;
	
		BufferedReader errStream = null;
		PrintWriter outStream = null;
		
		try {
			logger.finest("Running command '" + command + "'");
			
			// check batch size - use command line arguments if 1
			Process proc = null;
			if (!fBatchMode) {
				
				// length of the batch MUST be 1
				if(samples.length != 1){
					throw new SampleEvaluatorException("The batch size must be one and not " + samples.length + " since we are not in batch mode.");
				}
				
				// get the single point that is being submitted
				SamplePoint point = samples[0];
				// PROBLEEM: wat als batch mode 1 punt submit? -> conflict!
				String[] commands = new String[point.getInputDimension()+1];
				commands[0] = command;
				for (int i = 0; i < point.getInputDimension(); ++i)
					commands[i+1] = "" + point.getInputParameter(i);
				
				// execute command
				proc = fRuntime.exec(commands);
			}
			
			// batch mode, use stdin
			else {
				
				// start up program
				proc = fRuntime.exec(command);
				
				// get the std input
				outStream = new PrintWriter(new BufferedWriter(new OutputStreamWriter(proc.getOutputStream())));
				
				// write the batch size to the output stream
				outStream.println(samples.length);
				// write the input values to the output stream
				for (SamplePoint sample : samples) {
					for (double p : sample.getInputParameters())
						outStream.println(p);
				}
				outStream.flush();
			}
			
			//Get the std error output
			errStream =  new BufferedReader(new InputStreamReader(proc.getErrorStream()));
			
			// get the std output, and start emptying the stdout buffer immediately
			// to prevent blocking
			ProcessInputStream inStream = new ProcessInputStream(proc.getInputStream());

			// wait for the process to finish
			int exitValue = -1;
			boolean infiniteLoop = false;
				
			if ( fTimeout > 0 )	{
				long startTime = System.currentTimeMillis();
				while ( true ) {
					try {
						exitValue = proc.exitValue();
						break;
					} catch ( IllegalThreadStateException e ) {
						//thrown if the process has not yet terminated
					}
					
					if ( System.currentTimeMillis() - startTime > fTimeout ) {
						//ok, we've waited long enough, the process seems hung, quit waiting
						infiniteLoop = true;
						break;
					}
					Thread.sleep( 100 );					
				}
			} else {
				// Wait for the process to terminate without a timeout
				exitValue = proc.waitFor();
			}
			
			// check error in process input stream
			if (inStream.isIOException()) {
				SampleEvaluatorException ex = new SampleEvaluatorException( "IOException in ProcessInputStream, reading stdout of executable failed");
				logger.log(Level.SEVERE,ex.getMessage(),ex);
				throw ex;
			}
			
			if (errStream.ready()) {
				logger.log( Level.WARNING, "The process produced the following error output" );
				while(errStream.ready())
					logger.log( Level.WARNING, "Error stream: " +  errStream.readLine() );
			}

			//did the process hang?
			if (infiniteLoop) {
				//Remember to always explicitly close all streams before destroying the process!
				//This is important!!
				Util.close(inStream);
				Util.close(outStream);
				Util.close(errStream);
				proc.destroy();
				
				//we dont treat this as fatal, hence the use of InteruptedException over SampleEvaluatorException
				InterruptedException ex = new InterruptedException( "Evaluation of sample aborted, timeout exceeded" );				
				logger.log(Level.WARNING,ex.getMessage(),ex);
				throw ex;
			}

			if (exitValue != 0) {
				logger.log( Level.WARNING, "External process did NOT exit cleanly, error code = " + exitValue );
			} else {
				logger.log( Level.FINEST, "External command exited cleanly");
			}
			
			Scanner inScanner = new Scanner(new BufferedInputStream(inStream));
			
			// if in batch mode, we expect a line containing input+output values for one sample
			// amount of samples returned does not have to match the amount of samples given
			if (fBatchMode) {
				int inD = samples[0].getInputDimension(), outD = samples[0].getOutputDimension();
				while (inScanner.hasNext()) {
					SamplePoint point = new SamplePoint(inD, outD);
					point.inputsAndOutputsFromStream(inScanner);
					batch.addEvaluatedSample(point);
				}
			}
			
			// if in normal mode, we expect output values only, one for each input sample specified
			else {
				for (SamplePoint point : samples) {
					point.outputsFromStream(inScanner);
					batch.addEvaluatedSample(point);
					logger.finest("Evaluated sample point = " + point);
				}
			}
			
			int ignoredCtr = 0;
			while (inScanner.hasNext()){
				String s = inScanner.next();
				logger.log(Level.FINEST, "This extra simulator output line was ignored: " + s);
				++ignoredCtr;
			}
			
			if(ignoredCtr > 0){
				String msg = "More output was produced by the simulator than expected: " + ignoredCtr + " non-output lines were ignored";

				//we dont treat this as fatal, hence the use of InteruptedException over SampleEvaluatorException
				InterruptedException ex = new InterruptedException(msg);
				logger.log(Level.FINER,ex.getMessage(),ex);
				throw ex;
			}
			
			//Remember to always explicitly close all streams before destroying the process!
			//This is important!!
			Util.close(inStream);
			Util.close(outStream);
			Util.close(errStream);
			
			proc.destroy();
			
			logger.finest("Native process object destroyed");
			
		} catch ( InterruptedException e ) {
			SampleEvaluatorException ex = new SampleEvaluatorException( "InterruptedException while executing the command + '" + command + "' , error: " + e.getMessage() );
			ex.initCause(e);
			logger.log(Level.SEVERE,ex.getMessage(),ex);
			throw ex;
		} catch ( IOException e ) {
			SampleEvaluatorException ex = new SampleEvaluatorException( "IOException while executing the command + '" + command + "' , error: " + e.getMessage() );
			ex.initCause(e);
			logger.log(Level.SEVERE,ex.getMessage(),ex);
			throw ex;
		}
	}
}
