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

import ibbt.sumo.contrib.HashCodeUtil;
import ibbt.sumo.util.Util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.Serializable;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;


/**
 * SamplePoint keeps track of all the info related to one point that is submitted
 * for simulation/evaluation. This object represents a task for the 
 * SampleEvaluator: for each given set of input parameters, the SampleEvaluator has 
 * to calculate the output parameters.
 */
public class SamplePoint implements Serializable {
	private static final long serialVersionUID = 1L;
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.SamplePoint");
	
	
	/**
	 * Input-parameters. Must be assigned in the constructor.
	 * They can optionally be changed by the evaluator if the proposed parameters could not be evaluated.
	 */
	private double[] fInputParameters;
	
	/**
	 * The output values of the evaluation/simulation.
	 * initially null, which indicates that this point hasn't been evaluated yet.
	 */
	private double[] fOutputParameters;
	
	/**
	 * Unique ID generated for every sample point.
	 */
	private long fId;
	
	/**
	 * Defines which inputs are used in modeling.
	 */
	private boolean[] fUsed;
	
	/**
	 * Priority of this sample point (how important is it)
	 * 0: highest priority, 1: lowest priority
	 */
	private double priority;
	
	/**
	 * Static variable that is used to generate unique id's.
	 */
	private static long IdCounter = 0;
	
	public static long newID() {
		return IdCounter++;
	}

	private void init(){
		fId = newID();
		priority = 0.5;	
	}
	
	/**
	 * Create a sample point that has to be evaluated for the given input parameters.
	 * @param inputParameters
	 */
	public SamplePoint(double[] inputParameters, int outputDimension ) {
		fInputParameters = inputParameters;
		fOutputParameters = new double[outputDimension];
		init();
	}
	
	public SamplePoint(double[] inputParameters, double[] outputParameters ) {
		fInputParameters = inputParameters;
		fOutputParameters = outputParameters;
		init();
	}
	
	public SamplePoint(int inputDimension, int outputDimension) {
		fInputParameters = new double[inputDimension];
		fOutputParameters = new double[outputDimension];
		init();
	}
	
	public void setPriority(double p){
		//priority should always be bounded between 1 and 0
		priority = p;
	}
	
	public double getPriority(){
		return priority;
	}
	
	public long getId() {
		return fId;
	}

	public double[] getInputParameters() {
		return fInputParameters;
	}
	
	public double getInputParameter(int i) {
		assert (0 <= i && i < fInputParameters.length);
		return fInputParameters[i];
	}

	public void setInputParameters(double[] inputParameters) {
		fInputParameters = inputParameters;
	}

	public int getInputDimension() {
		return fInputParameters.length;
	}
	
	public double[] getOutputParameters() {
		return fOutputParameters;
	}
	
	public double getOutputParameter(int i) {
		assert (0 <= i && i < fOutputParameters.length);
		return fOutputParameters[i];
	}

	public void setOutputParameters(double[] outputParameters) {
		fOutputParameters = outputParameters;
	}
	
	public int getOutputDimension() {
		return fOutputParameters.length;
	}

	public String toString() {
		return "SamplePoint [ID: " + fId + "; Priority: " + priority + "; Input:" + inputsToString() + "; Output:" + outputsToString() + "]";
	}
	
	public SamplePoint getNull() {
		return null;
	}
	
	public String inputsToString() {
		return Util.doubleArrayToString( fInputParameters );
	}	
	
	public String outputsToString() {
		return Util.doubleArrayToString( fOutputParameters );
	}
	
	/**
	 *  Read outputs from an InputStream object by using a scanner object
	 */
	static Pattern fSearch = Pattern.compile( "[ \\t\\r]*[\\-+]?[0-9]+(\\.[0-9]+)?([eE][\\-+]?[0-9]+)?[ \\t\\r]*" );
	
	public void inputsAndOutputsFromStream(Scanner scanner) throws SampleEvaluatorException {
		String string = "";
		scanner.useDelimiter( "[ \n]+" );
		for ( int i=0;i<fInputParameters.length+fOutputParameters.length; ) {
			if ( scanner.hasNext() ){
				try {
					string = scanner.next();
					if ( fSearch.matcher( string ).matches() ) {
						if (i < fInputParameters.length)
							fInputParameters[i++] = Double.parseDouble(string);
						else
							fOutputParameters[i++ - fInputParameters.length] = Double.parseDouble(string);
					} else {
						logger.log( Level.FINEST, "This simulator output line was ignored: " + string );
					}
				} catch ( NumberFormatException e ) {
					SampleEvaluatorException ex = new SampleEvaluatorException( "NumberFormaException while parsing InputStream : " + e.getMessage() + "  Last string read: " + string );
					ex.initCause(e);
					logger.log(Level.SEVERE,ex.getMessage(),ex);
					throw ex;
				}
			}else{
				SampleEvaluatorException ex
					= new SampleEvaluatorException( "There are not enough doubles on stream to fill this SamplePoint (inputs and outputs), "
							+ "expected " + (fInputParameters.length+fOutputParameters.length) + ", got " + i );
				logger.log(Level.SEVERE,ex.getMessage(),ex);
				throw ex;
			}
		}
		logger.finest((fInputParameters.length+fOutputParameters.length) + " values (input and output) read from stream");
	}
	
	
	/**
	 *  Read outputs from an InputStream object by using a scanner object
	 */
	public void outputsFromStream(Scanner scanner) throws SampleEvaluatorException {
		String string = "";
		scanner.useDelimiter( "\n" );
		for ( int i=0;i<fOutputParameters.length; ) {
			if ( scanner.hasNext() ){
				try {
					string = scanner.next();
					if ( fSearch.matcher( string ).matches() ) {
						fOutputParameters[i++] = Double.parseDouble(string);
					} else {
						logger.log( Level.FINEST, "This simulator output line was ignored: " + string );
					}
				} catch ( NumberFormatException e ) {
					SampleEvaluatorException ex = new SampleEvaluatorException( "NumberFormaException while parsing InputStream : " + e.getMessage() + "  Last string read: " + string );
					ex.initCause(e);
					logger.log(Level.SEVERE,ex.getMessage(),ex);
					throw ex;
				}
			}else{
				SampleEvaluatorException ex
					= new SampleEvaluatorException( "There are not enough doubles on stream to fill this SamplePoint, "
							+ "expected " + fOutputParameters.length + ", got " + i );
				logger.log(Level.SEVERE,ex.getMessage(),ex);
				throw ex;
			}
		}
		logger.finest(fOutputParameters.length + " output values read from stream");
	}

	public void outputsFromFile(File f) throws SampleEvaluatorException{
		try {
			outputsFromStream(new Scanner(new FileInputStream(f)));
		} catch (FileNotFoundException e) {
			SampleEvaluatorException ex = new SampleEvaluatorException("Non existing file to read samplepoint outputs from",e);
			logger.log(Level.SEVERE,ex.getMessage(),ex);
			throw ex;
		}
	}
	

	//BEWARE: change this method and you must change equals as well!
	public int hashCode(){
		  int result = HashCodeUtil.SEED;
	      result = HashCodeUtil.hash( result, getInputParameters() );
	      result = HashCodeUtil.hash( result, getOutputParameters() );
	      return result;
	}
	
	// Complex method to compare up to certain sensivity
	public enum EqualType { BOTH, INPUT, OUTPUT } ;
	public boolean equalTo( SamplePoint other, double tolerance, EqualType et ) {
			
		if ( et != EqualType.OUTPUT ) {
			if( getInputParameters().length != other.getInputParameters().length )
				return false;
			
			for(int i = 0; i < getInputParameters().length;++i ){
				if(getInputParameter(i) < other.getInputParameter(i) - tolerance 
						|| getInputParameter(i) > other.getInputParameter(i) + tolerance){
					return false;
				}
			}
		}

		if ( et != EqualType.INPUT ) {
			if ( getOutputParameters().length != other.getOutputParameters().length ) 
				return false;
			
			for(int i = 0; i < getOutputParameters().length;++i ){
				if(getOutputParameter(i) < other.getOutputParameter(i) - tolerance 
						|| getOutputParameter(i) > other.getOutputParameter(i) + tolerance){
					return false;
				}
			}
		}

		return true;
	}
	
	//BEWARE: change this method and you must change hashcode as well!
	public boolean equals(Object obj){
		if(obj == null) {
			return false;
		}
	
		if(this == obj){
			return true;
		}
		
		if(!(obj instanceof SamplePoint))
			return false;
		
		return equalTo( (SamplePoint) obj, Math.ulp(0.0), EqualType.BOTH ); 
	}
}
