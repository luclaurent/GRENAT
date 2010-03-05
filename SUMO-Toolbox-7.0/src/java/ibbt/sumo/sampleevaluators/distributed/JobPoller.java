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

import java.util.LinkedList;
/**
 * Distributed backends need their own poller to check for 
 * job status information.  Such pollers should subclass this class
 */
public abstract class JobPoller implements Runnable {
	private int interval = -1;
	private String location = null;
	private String mask = null;
	private LinkedList<JobFinishedEventListener> listeners 
				= new LinkedList<JobFinishedEventListener>();

	/**
	 * Create a new poller
	 * @param directory the location to monitor for result files
	 */
	public JobPoller(String location){
		setInterval(20);
		this.location = location;
	}

	public void addListener(JobFinishedEventListener list){
		listeners.add(list);
	}
	
	public void removeListener(JobFinishedEventListener list){
		listeners.remove(list);
	}
	
	protected void sendEvent(JobEvent event){
		for(JobFinishedEventListener l : listeners){
			l.jobFinished(event);
		}
	}

	public void setInterval(int sec){
		if(sec < 20) sec = 20;
		interval = sec;
	}
	
	public int getInterval(){
		return interval;
	}
	
	public String getMask() {
		return mask;
	}

	/**
	 * Poll for files whose name match this mask
	 * @param mask
	 */
	public void setMask(String mask) {
		this.mask = mask;
	}

	public String getLocation(){
		return location;
	}
	
	public abstract void stopPolling();
	public abstract boolean isPolling();
}
