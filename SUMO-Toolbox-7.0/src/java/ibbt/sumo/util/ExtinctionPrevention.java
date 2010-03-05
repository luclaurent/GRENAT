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
** Revision: $Id: ExtinctionPrevention.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import java.util.Hashtable;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.logging.Logger;

/**
 * A helper class that takes a the current population, compares it with the previous
 * population and ensures that the current population contains at least minCount individuals of
 * each model type (copying them over from the previous population)
 * 
 * WARNING: Code is hard to understand and could use cleaning up
 * 
 * @author dgorissen
 *
 */
public class ExtinctionPrevention {
	Hashtable<String, Container> curMap = new Hashtable<String, Container>();
	Hashtable<String, Container> prevMap = new Hashtable<String, Container>();
	LinkedList<Pair<Double, Double>> replaceMentList = new LinkedList<Pair<Double, Double>>();
	int minCount = 0;
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.util.ExtinctionPrevention");
	
	public ExtinctionPrevention(String[] curTypes, double[] curIndices, double[] curScores,
								String[] prevTypes, double[] prevIndices, double[] prevScores, int minCount){
	
		this.minCount = minCount;
		
		Container c = null;

		//build the current map
		for(int i=0;i < curTypes.length;++i){
			if(curMap.containsKey(curTypes[i])){
				c = curMap.get(curTypes[i]);
				c.indices.add(curIndices[i]);
				c.scores.add(curScores[i]);
			}else{
				String type = curTypes[i];
				double[] in = {curIndices[i]};
				double[] sc = {curScores[i]};
				c = new Container(type,in,sc);
				curMap.put(type,c);
			}
		}

		//build the previous map
		for(int i=0;i < prevTypes.length;++i){
			if(prevMap.containsKey(prevTypes[i])){
				c = prevMap.get(prevTypes[i]);
				c.indices.add(prevIndices[i]);
				c.scores.add(prevScores[i]);
			}else{
				String type = prevTypes[i];
				double[] in = {prevIndices[i]};
				double[] sc = {prevScores[i]};
				c = new Container(type,in,sc);
				prevMap.put(type,c);
			}
		}
		
		//Add empty entries for types that have gone extinct in the current generation
		Iterator<String> it = prevMap.keySet().iterator();
		while(it.hasNext()){
			String k = it.next();
			if(!curMap.containsKey(k)){
				curMap.put(k, new Container(k));
			}
		}
		
		logger.fine("Extinction prevention object constructed, curMap is: ");
		this.printCurMap();

	}
	
	public void doIt(){
		Container pc = null;
		Container cc = null;
		Container tmp = null;
		
		//Get the containers with less than minCount entries, these need to be replenished
		Hashtable<String,Container> needSaving = getContainersOfMaxSize(curMap, minCount);

		//Dont save ensembles
		if(needSaving.contains("EnsembleModel")){
			needSaving.remove("EnsembleModel");
		}
		
		if(needSaving.size() < 1){
			//Nobody threatened with extinction, return
			return;
		}else{
			logger.fine("************* The following types need saving *********************");
			Iterator<String> it = needSaving.keySet().iterator();
			while(it.hasNext()){
				logger.fine(needSaving.get(it.next()).toString());
			}
		}
		
		//Get all the containers with more than minCount entries
		Hashtable<String,Container> dontNeedSaving = getContainersOfMinSize(curMap, minCount);
		

		Iterator<String> it = needSaving.keySet().iterator();
		while(it.hasNext()){
			String k = it.next();
			
			//Get the current container that needs replenishing
			cc = curMap.get(k);
			
			//Get the matching container from the previous generation
			pc = prevMap.get(k);
			
			if(pc == null){
				//Possible in the case where the first time ensmbles arise their number is smaller than minCount
				logger.fine("***** the type " + k + " exists in the current but not in the previous gen, ignoring");
			}else{
				int added = cc.add(pc,minCount);
				
				//So if for example 5 models were re-inserted we need to delete 5 other models to ensure the population
				//size stays the same
				Boolean b = true;
				while(added > 0 && b){
					b = false;
					Iterator<String> it2 = dontNeedSaving.keySet().iterator();
					while(added > 0 && it2.hasNext()){
						String l = it2.next();
						
						if(curMap.get(l).size()>minCount){
							tmp = curMap.get(l);
					
							Pair<Double,Double> p = new Pair<Double, Double>(-1.0,-1.0);
							p.setFirst(tmp.indices.getLast());
							p.setSecond(cc.indices.get(cc.size()-added));
							replaceMentList.add(p);
	
							//Update the added entry so it uses the index of the enty we will remove
							cc.indices.set(cc.size()-added,tmp.indices.getLast());
	
							tmp.removeLast();
							--added;
							b = true;
						}
						
					}
				}
				
				//Not sure if this will ever happen
				if(b == false){
					logger.warning("It was impossible to replenish (almost) extinct models without driving others towards extinction");
					while(added > 0){
						cc.removeLast();
						--added;
					}
				}
			}
		}

		logger.fine("Extinction prevention done, curMap is: ");
		this.printCurMap();

	}
	
	private Hashtable<String,Container> getContainersOfMinSize(Hashtable<String,Container> map, int size){
		Hashtable<String,Container> newMap = new Hashtable<String,Container>();
		
		Iterator<String> it = map.keySet().iterator();
		while(it.hasNext()){
			String k = it.next();
			if(map.get(k).size() > size){
				newMap.put(k,map.get(k));
			}
		}
		return newMap;
	}
	
	private Hashtable<String,Container> getContainersOfMaxSize(Hashtable<String,Container> map, int size){
		Hashtable<String,Container> newMap = new Hashtable<String,Container>();
		
		Iterator<String> it = map.keySet().iterator();
		while(it.hasNext()){
			String k = it.next();
			if(map.get(k).size() < size){
				newMap.put(k,map.get(k));
			}
		}
		return newMap;
	}
	
	public void printReplacementList(){

		for(Pair<Double,Double> p : replaceMentList){
			System.out.println("index " + p.getFirst() + " in the cur list is replaced by index " + p.getSecond() + " from the previous list");
		}

		double[][] list = getReplacementList();
		
		for(int i=0;i<list.length;++i){
			System.out.println(list[i][0] + "->" + list[i][1]);
		}
		
	}
	
	public void printCurMap(){
		logger.fine("--- Curmap is:");

		Iterator<String> it = curMap.keySet().iterator();
		while(it.hasNext()){
			String k = it.next();
			logger.fine(curMap.get(k).toString());
		}
	
		logger.fine("end curmap ---");
	}
	
	public double[][] getReplacementList(){
		double[][] list = new double[replaceMentList.size()][2];
		
		int i = 0;
		for(Pair<Double,Double> p : replaceMentList){
			list[i][0] = p.getFirst();
			list[i][1] = p.getSecond();
			++i;
		}
		return list;
	}
	                                                                               
	
	//Some testcode
	public static void main(String[] args) {
		String[] curTypes = {"K","R","R","R","E","R","R","S","E","R","R","R","E","E","E","R","E","R","R","R","R"};
		double[] curIndices = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21};
		double[] curScores = {2.549523e-01, 1.171405e-01,                                                                                        
				1.280257e-01,                                                                                        
				5.103363e-02,                                                                                        
				9.113724e-02,                                                                                        
				1.171405e-01,                                                                                        
				1.120471e-01,                                                                                        
				1.238908e-01,                                                                                             
				1.062625e-01,                                                                                        
				1.171405e-01,                                                                                        
				3.328806e-01,                                                                                        
				1.171405e-01,                                                                                        
				1.062625e-01,                                                                                        
				9.996795e-02,                                                                                        
				9.113724e-02,                                                                                        
				3.328806e-01,                                                                                        
				1.527579e-01,                                                                                        
				1.280257e-01,                                                                                        
				1.290415e-01,                                                                                        
				1.280257e-01,                                                                                       
				6.820149e-02,};  
		
		String[] prevTypes = {"K","R","R","R","E","E","R","S","S","E","R","R","R","S","E","K","R","E","R","R","R"};
		double[] prevIndices = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21};
		double[] prevScores = {2.549523e-01,1.171405e-01,1.280257e-01,5.103363e-02,1.527579e-01,9.113724e-02,1.171405e-01,1.238908e-01,1.257601e-01,1.062625e-01,1.171405e-01,3.328806e-01,1.171405e-01,1.238908e-01,9.113724e-02,2.220616e-01,3.328806e-01,1.527579e-01,1.280257e-01,1.280257e-01,1.290415e-01};

		int minCount = 2;
		
		ExtinctionPrevention e = new ExtinctionPrevention(curTypes,curIndices,curScores,prevTypes,prevIndices,prevScores,minCount);
		
		e.printCurMap();
		e.doIt();
		e.printCurMap();
		e.printReplacementList();
	}
	
	//Helper class
	private class Container {
		public String type;
		public LinkedList<Double> indices = new LinkedList<Double>();
		public LinkedList<Double> scores = new LinkedList<Double>();
		
		public Container(String type, double[] indices, double[] scores){
			this.type = type;
			for(Double d : indices) this.indices.add(d);
			for(Double d : scores) this.scores.add(d);			
		}

		public Container(String type){
			this.type = type;
		}

		public int add(Container c, int size){
			int added = 0;
			int index = 0;
			//Add the models in c to fill up the models in this container (up to size)
			for(double s : c.scores){
				index = this.scores.indexOf(s);
				if(index < 0){
					//only add different models
					if(size() < size){
						this.scores.add(s);
						this.indices.add(c.indices.get(c.scores.indexOf(s)));
						++added;
					}
				}
			}
			
			//its possible there are not enough different models to fill up this container
			//in that case add duplicates
			while(size() < size){
				this.scores.add(c.scores.getFirst());
				this.indices.add(c.indices.getFirst());
				++added;
			}
			return added;
		}
		
		public void removeLast(){
			this.scores.removeLast();
			this.indices.removeLast();
		}
		
		public int size(){
			return indices.size();
		}
		
		public String toString(){
			String s = "Type: " + type + "\n"
						+ "   size: " + size() + "\n"
						+ "   indices: " + indices.toString() + "\n"
						+ "   scores: " + scores.toString() + "\n";
			return s;
		}
	}
	
}


