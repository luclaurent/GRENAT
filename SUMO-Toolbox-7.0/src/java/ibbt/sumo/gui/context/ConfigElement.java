package ibbt.sumo.gui.context;
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

import org.dom4j.DocumentHelper;
import org.dom4j.Element;

/**
 * Holds the informatio about a configuretion element selected by the user
 *
 * @author Sasa Berberovic
 */
public class ConfigElement {
    private String name;
    private String id;
    private String type;
    private String description;

    /**
     * Create a config element with name and id
     *
     * @param name  name of the configuration element
     * @param id    id of the configuration element
     *
     */
    public ConfigElement(String name, String id, String type, String descr) {
        this.name = name;
        this.id = id;
        this.type = type;
        this.description = descr;
    }

    /**
     *
     * @param name
     * @param text
     */
    public ConfigElement(String name, String text) {
        this.name = name;
        this.id = text;
        this.type = "";
        this.description = "";
    }

    /**
     * Getter for config element id
     *
     * @return String id of this element
     */
    public String getId() {
        return id;
    }

    /**
     *
     * @param type
     */
    public void setType(String type) {
        this.type = type;
    }

    /**
     * 
     * @return
     */
    public String getType() {
        return type;
    }



    /**
     * Getter for config element name
     *
     * @return String name of this element
     */
    public String getName() {
        return name;
    }

    /**
     * Getter for the description of the config element
     * 
     * @return String description of the config element
     */
    public String getDescription() {
        return description;
    }


    /**
     * Checks if two config elements are equal: id == ce.id and name == ce.name
     *
     * @return true     if ids and names match
     * @return false    if ids and name don't match
     */
    public boolean equals(ConfigElement ce){
        return (this.name.equals(ce.getName()) && this.id.equals(ce.getId()));
    }

    /**
     * 
     * @return
     */
    public Element getElement(){
        Element e = DocumentHelper.createElement(this.name);
        e.addText(this.id);

        return e;
    }
}
