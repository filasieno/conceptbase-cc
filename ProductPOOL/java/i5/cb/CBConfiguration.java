/*
The ConceptBase.cc Copyright

Derived from ConceptBase.cc, originally created by the ConceptBase Team under a FreeBSD-style license.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the authors
and should not be interpreted as representing official policies, either expressed or implied,
of the ConceptBase Team.


The ConceptBase Team is represented by

Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
package i5.cb;

import java.awt.Color;
import java.util.Properties;
import java.util.StringTokenizer;
import java.util.logging.Level;

import javax.swing.JRadioButtonMenuItem;
import java.io.*;

/**
 * Hold the userconfiguration for the CBjavaInterface.
 * The config is stored to a file in the user's homedirectory when CBEditor is finished and loaded again
 * when it's started. The file's name is defined CONFIGFILE_NAME.
 */
public class CBConfiguration {

    /**
    * The name of the editor's configfile
    */
    private static final String CONFIGFILE_NAME=".CBjavaInterface";

    private final static String KEY_OPTION_SAVE_LAYOUT_WITH_GRAPHTYPES ="SaveLayoutWithGraphTypes";
    private final static String KEY_OPTION_COMPONENTVIEW = "ComponentView";
    private final static String KEY_OPTION_INVALIDOBJSMETHOD = "InvalidObjectsMethod";

    private final static String KEY_RECENT_CONNECTIONS = "RecentConnections";
    private final static String KEY_RECENT_STARTINGOBJ = "InitialObjectsFor_";
    private final static String KEY_RECENT_GRAPHPALETTE = "JavaGraphicalPaletteFor_";
    private final static String KEY_RECENT_QUERIES = "RecentQueriesFor_";
    private final static String KEY_OPTION_DD_BACKGROUNDCOLOR ="DiagramDesktopBackgroundColor";
    private final static String KEY_OPTION_TIMEOUT="ConnectionTimeout";
    private final static String KEY_OPTION_LPICALL="LPICall";
    private final static String KEY_OPTION_LOADMODELPATH="PathForLoadModel";
    private final static String KEY_OPTION_LOADLAYOUTPATH="PathForLayout";
    private final static String KEY_OPTION_USE_QUERYRESULTWINDOW="UseQueryResultWindow";
    private final static String KEY_OPTION_CALL_TELOSPARSER="PreParseTelosFrames";
    private final static String KEY_OPTION_SHOW_LINE_NUMBERS="ShowLineNumbers";
    private final static String KEY_OPTION_POPUP_DELAY="PopupMenuDelay";
    private final static String KEY_OPTION_POPUP_BLOCKS="PopupMenuBlocks";
    private final static String KEY_OPTION_AUTO_LAYOUT="AutoLayout";
    private final static String KEY_OPTION_PUBLIC_CBSERVER="PublicCBserver";
    private final static String KEY_OPTION_CLICK_ACTIONS="ClickActions";
    private final static String KEY_OPTION_NODELEVEL_AWARE="NodeLevelAware";
    private final static String KEY_OPTION_MODULE_SEPARATOR="ModuleSeparator";
    private final static String KEY_OPTION_CBIVA_SMALLFONT="CBIvaSmallFont";
    private final static String KEY_OPTION_CBIVA_LARGEFONT="CBIvaLargeFont";
    private final static String KEY_OPTION_DERIVED_LINKS="DerivedLinks";
    private final static String KEY_OPTION_BROWSER_WINDOWS="CBIvaBrowserWindows";
    private final static String KEY_OPTION_DARKMODE="DarkMode";

    private final static String KEY_OPTION_DEBUG_LEVEL="DebugLevel";

    private final static String KEY_OPTION_SHOWLINKCATEGORY="ShowLinkCategory";

    public final static String VALUE_TREE = "tree";
    public final static String VALUE_FRAME = "frame";
    public static final String VALUE_DEFAULT_DD_BACKGROUNDCOLOR ="255, 255, 255";
    public static final String VALUE_DEFAULT_PUBLIC_CBSERVER ="cbserver.iit.his.se";  // hope it is online!
    public final static String VALUE_TRUE = "true";
    public final static String VALUE_FALSE = "false";
    public final static String VALUE_MARK = "mark";
    public final static String VALUE_REMOVE = "remove";
    public final static String VALUE_SLASH = "/";
    public final static String VALUE_DASH = "-";
    public final static String VALUE_SMALLFONT = "12f";
    public final static String VALUE_LARGEFONT = "18f";

    private final static int PROPERTIES_MAXVALUES = 10;
    private final static String PROPERTIES_DELIMINATOR =", ";

    private static Properties m_Properties=null;

    private static boolean bSessionDarkMode = false;  // may be set via changing look&feel during a session

    /**
     * Defines defaultvalues for all options and tries to load a properties object from a file.
     * Uses all default-options that have not been overridden by the file's porperties.
     */
    public static void openConfig() {

        // Properties have already been loaded
        if(m_Properties!=null)
            return;

        m_Properties = new Properties();

        String sConfigFile = "";
        String userHome= "";

        try {
            userHome=System.getProperty("user.home");
            sConfigFile =System.getProperty("user.home") + "/" + CONFIGFILE_NAME;
            m_Properties.load(new java.io.FileInputStream(sConfigFile));
        } catch (java.security.AccessControlException ace) {
            // probably running as applet
        } catch (java.io.FileNotFoundException fe) {
            java.util.logging.Logger.getLogger("global").fine(
                "Found no config file '" + sConfigFile + "'");
        } catch (java.io.IOException ie) {
            java.util.logging.Logger.getLogger("global").warning(ie.getMessage());
        }

        // Set defaults
        if(!m_Properties.containsKey(KEY_OPTION_SAVE_LAYOUT_WITH_GRAPHTYPES))
           m_Properties.setProperty(KEY_OPTION_SAVE_LAYOUT_WITH_GRAPHTYPES,VALUE_TRUE);
        if(!m_Properties.containsKey(KEY_OPTION_DD_BACKGROUNDCOLOR))
            m_Properties.setProperty(KEY_OPTION_DD_BACKGROUNDCOLOR,VALUE_DEFAULT_DD_BACKGROUNDCOLOR);
        if(!m_Properties.containsKey(KEY_OPTION_COMPONENTVIEW))
            m_Properties.setProperty(KEY_OPTION_COMPONENTVIEW,VALUE_FRAME);
        if(!m_Properties.containsKey(KEY_OPTION_INVALIDOBJSMETHOD))
            m_Properties.setProperty(KEY_OPTION_INVALIDOBJSMETHOD,VALUE_MARK);
        if(!m_Properties.containsKey(KEY_OPTION_TIMEOUT))
            m_Properties.setProperty(KEY_OPTION_TIMEOUT,"38000000");   // timeout in ms for waiting for an answer from CBserver
        if(!m_Properties.containsKey(KEY_OPTION_LPICALL))
            m_Properties.setProperty(KEY_OPTION_LPICALL,VALUE_FALSE);
        if(!m_Properties.containsKey(KEY_OPTION_USE_QUERYRESULTWINDOW))
            m_Properties.setProperty(KEY_OPTION_USE_QUERYRESULTWINDOW,VALUE_FALSE);
        if(!m_Properties.containsKey(KEY_OPTION_LOADMODELPATH))
            m_Properties.setProperty(KEY_OPTION_LOADMODELPATH,userHome);
        if(!m_Properties.containsKey(KEY_OPTION_CALL_TELOSPARSER))
            m_Properties.setProperty(KEY_OPTION_CALL_TELOSPARSER,VALUE_FALSE);
        if(!m_Properties.containsKey(KEY_OPTION_LOADLAYOUTPATH))
            m_Properties.setProperty(KEY_OPTION_LOADLAYOUTPATH,userHome);
        if(!m_Properties.containsKey(KEY_OPTION_SHOWLINKCATEGORY))
            m_Properties.setProperty(KEY_OPTION_SHOWLINKCATEGORY,"Proposition");
        if(!m_Properties.containsKey(KEY_OPTION_POPUP_DELAY))
            m_Properties.setProperty(KEY_OPTION_POPUP_DELAY,"0");
        if(!m_Properties.containsKey(KEY_OPTION_POPUP_BLOCKS))
            m_Properties.setProperty(KEY_OPTION_POPUP_BLOCKS,VALUE_FALSE);
        if(!m_Properties.containsKey(KEY_OPTION_AUTO_LAYOUT))
            m_Properties.setProperty(KEY_OPTION_AUTO_LAYOUT,VALUE_FALSE);
        if(!m_Properties.containsKey(KEY_OPTION_DEBUG_LEVEL))
            m_Properties.setProperty(KEY_OPTION_DEBUG_LEVEL,"WARNING");
        if(!m_Properties.containsKey(KEY_OPTION_SHOW_LINE_NUMBERS))
            m_Properties.setProperty(KEY_OPTION_SHOW_LINE_NUMBERS,VALUE_TRUE);
        if(!m_Properties.containsKey(KEY_OPTION_BROWSER_WINDOWS))
            m_Properties.setProperty(KEY_OPTION_BROWSER_WINDOWS,VALUE_FALSE);
        if(!m_Properties.containsKey(KEY_OPTION_DARKMODE))
            m_Properties.setProperty(KEY_OPTION_DARKMODE,VALUE_FALSE);
        else  // initialize the session dark/light mode flag from the config file
            bSessionDarkMode = (m_Properties.getProperty(KEY_OPTION_DARKMODE).equals(VALUE_TRUE));
        


        // Plain Windows and Mac clients get autoconnected to the default public CBserver
        // since we do not provide binaries for the CBserver on these platforms.
        // This clause should be disabled when binaries are also compiled for these platforms.
        // Windows 10 with 'bash' installed do not autoconnect to the default public CBserver.
        if(!m_Properties.containsKey(KEY_OPTION_PUBLIC_CBSERVER)) {
           if ((System.getProperty("os.name").indexOf("Windows") >= 0 && !bashInstalled() )
               ||
               System.getProperty("os.name").indexOf("Mac OS") >= 0)
             m_Properties.setProperty(KEY_OPTION_PUBLIC_CBSERVER,VALUE_DEFAULT_PUBLIC_CBSERVER);
           else
             m_Properties.setProperty(KEY_OPTION_PUBLIC_CBSERVER,"none");
        }

        if(!m_Properties.containsKey(KEY_OPTION_NODELEVEL_AWARE)) 
            m_Properties.setProperty(KEY_OPTION_NODELEVEL_AWARE,VALUE_TRUE);
        if(!m_Properties.containsKey(KEY_OPTION_MODULE_SEPARATOR))
            m_Properties.setProperty(KEY_OPTION_MODULE_SEPARATOR,VALUE_DASH);

        if(!m_Properties.containsKey(KEY_OPTION_CBIVA_SMALLFONT))
            m_Properties.setProperty(KEY_OPTION_CBIVA_SMALLFONT,VALUE_SMALLFONT);
        if(!m_Properties.containsKey(KEY_OPTION_CBIVA_LARGEFONT))
            m_Properties.setProperty(KEY_OPTION_CBIVA_LARGEFONT,VALUE_LARGEFONT);
    }

    /**
     * Stores the prperties object representing the configuration to disk
     */
    public static void storeConfig() {

        String sConfigFile = "";
        try {
            sConfigFile = System.getProperty("user.home") + "/" + CONFIGFILE_NAME;
            m_Properties.store(new java.io.FileOutputStream(sConfigFile),"ConceptBase Java Interface configurations file");
        } catch (java.security.AccessControlException ace) {
            // probably running as applet
        } catch (java.io.FileNotFoundException fe) {
            java.util.logging.Logger.getLogger("global").warning(fe.getMessage());
        } catch (java.io.IOException ie) {
            java.util.logging.Logger.getLogger("global").warning(ie.getMessage());
        }

    }

    /**
     * Determines the content of the big componentview of the diagramNodes
     *
     * @param view one of VALUE_TREE or VALUE_FRAME as defined in CBConstants.
     */
    public static void setComponentView(String view) {
        assert(view == VALUE_TREE)
            || (view == VALUE_FRAME);
        m_Properties.setProperty(KEY_OPTION_COMPONENTVIEW, view);
    }

    /**
     * Sets the two radiobuttons (which form a buttongroup) according to the setting of the diagramNode's component view
     *
     */
    public static void getComponentView(JRadioButtonMenuItem tree, JRadioButtonMenuItem frame) {
        String value =m_Properties.getProperty(KEY_OPTION_COMPONENTVIEW);
        if (value.equals(VALUE_TREE)) {
            tree.setSelected(true);
        } else {
            frame.setSelected(true);
        }
    }

    /**
     * Tell the config what to do with invalid nodes.
     *
     * @param method one of VALUE_MARK or VALUE_REMOVE as defined in
     */
    public static void setInvalidOjsMethod(String method) {
        assert (method == VALUE_REMOVE) || (method == VALUE_MARK);
        m_Properties.setProperty(KEY_OPTION_INVALIDOBJSMETHOD,method);
    }


    /**
     * Sets the two radiobuttons (which form a buttongroup) according to what to do with invalid nodes on the diagramDesktop.
     *
     */
    public static String getInvalidOjsMethod(JRadioButtonMenuItem mark,JRadioButtonMenuItem remove) {
        String value =m_Properties.getProperty(KEY_OPTION_INVALIDOBJSMETHOD);
        if ((mark != null) && (remove != null)) {
            if (value.equals(VALUE_MARK)) {
                mark.setSelected(true);
            } else {
                remove.setSelected(true);
            }
        }
        return value;
    }

    /**
     * Tells if the graphtypes are also to be saved when a layout is saved.
     *
     * @return true if graphTypes are saved as well, false otherwise.
     */
    public static boolean getSaveGraphTypes() {
        String value =m_Properties.getProperty(KEY_OPTION_SAVE_LAYOUT_WITH_GRAPHTYPES);
        if (value.equals(VALUE_TRUE)) {
            return true;
        } else {
            return false;

        }
    }

    /**
     * Test if 'bash.exe' is installed; this indicates that Windows 10 has the Linux sub-system installed
     *
     * @return true if 'bash.exe' is installed
     */

   public static boolean bashInstalled() {
     boolean result = false;
     try { if (System.getProperty("os.name").toLowerCase().indexOf("windows") >= 0) {
             File bashfile = new File("c:\\windows\\system32\\bash.exe");
             result = bashfile.exists();
          }
     } catch (Exception e) {}
     return result;
   }

   public static boolean plainWindows() {
     boolean result = false;
     try { if (System.getProperty("os.name").toLowerCase().indexOf("windows") >= 0) {
             result = true;
             File bashfile = new File("c:\\windows\\system32\\bash.exe");
             if (bashfile.exists())
               result = false;
          }
     } catch (Exception e) {}
     return result;
   }

   public static boolean anyLinux() {
     boolean result = false;
     try { if (System.getProperty("os.name").toLowerCase().indexOf("linux") >= 0) {
             result = true;
          }
     } catch (Exception e) {}
     return result;
   }

   public static boolean anyWindows() {
     boolean result = false;
     try { if (System.getProperty("os.name").toLowerCase().indexOf("windows") >= 0) {
             result = true;
          }
     } catch (Exception e) {}
     return result;
   }

   public static String defaultCbHome() {
     String result = "";
     try { if (System.getProperty("os.name").toLowerCase().indexOf("windows") >= 0) {
             result = "C:\\conceptbase";
         }
     } catch (Exception e) {}
     return result;
   }

  public static String getCbHome() {
     String result = CBConfiguration.defaultCbHome();
     try { result = System.getProperty("CB_HOME", CBConfiguration.defaultCbHome());
     } catch (Exception e) {}
     return result;
   }


   public static String getCBserverCmd() {
     String cbHome = getCbHome();
     if (anyWindows())
       return cbHome + "\\cbserver.bat";
     else
       return cbHome+ "/cbserver";
   }

// handle relative directory paths as being relative to the user home directory
   public static String getHomedLocation(String dir) {
     String cbHome = getCbHome();
     if (dir.toLowerCase().indexOf(":") > 0 || dir.toLowerCase().startsWith("/"))
       return dir;
     if (plainWindows())
       return cbHome + "\\" + dir;
     if (bashInstalled())
       return "$HOME/" + dir;
     if (anyLinux()) {
       try {
          String homedir = System.getProperty("user.home");
          if (homedir != null)
            return homedir + "/" + dir;
       } catch (Exception e) {}
     }
     return dir;
   }




/**
 * Sets wheter graphTypes are to be saved in a graphLayout.
*
 * @param value One of VALUE_TRUE or VALUE_FALSE as defined in GEConstants
 */
    public static void setSaveGraphTypes(String value) {
          assert(value == VALUE_TRUE)
            || (value == VALUE_FALSE);

        m_Properties.setProperty(
            KEY_OPTION_SAVE_LAYOUT_WITH_GRAPHTYPES,
            value);
    }

    /**
     * Adds a new querystring to the history of queries for a certain server.
     *
     * @param sQuery the querystring
     * @param sHost the server's host name
     * @param sPort the server's portnumber
     */
    public static void addRecentQuery(String sQuery,String sHost,String sPort) {
        addProperty(KEY_RECENT_QUERIES + sHost + "/" + sPort,sQuery);
    }

/**
 * Gets all queries that have been asked to a certain ConceptBase server recently
 *
 * @param sHost the server's host
 * @param sPort the server's port
 *
 * @return an Array of String containing all queries asked so far.
 */
    public static String[] getRecentQueries(String sHost, String sPort) {
        return tokenize(
            m_Properties.getProperty(
                KEY_RECENT_QUERIES + sHost + "/" + sPort));
    }

    /**
     *  Returns an array containing the addresses and ports of all CBservers visited so far.
     *
     * @return every even index of the array contains a server address and the following (odd) index contains the portnumber
     */
    public static String[] getRecentServers() {
        String[] entries =tokenize(m_Properties.getProperty(KEY_RECENT_CONNECTIONS));
        String[] rv = new String[entries.length * 2];
        for (int i = 0; i < entries.length; i++) {
            rv[2 * i] = tokenize(entries[i], "/")[0];
            rv[2 * i + 1] = tokenize(entries[i], "/")[1];
        }
        return rv;
    } //getRecentServers

    /**
     * Adds the address and port of another ConceptBase server we successfully connected to to the configuration
     *
     * @param  sHost  the CB server's address
     * @param  sPort  the port this server listens to
     */
    public static void addNewConnection(String sHost, String sPort) {
        appendProperty(KEY_RECENT_CONNECTIONS, sHost + "/" + sPort);
    } //addNewConnection

    /**
     *  Returns all former startingobjects for the specified cbserver
     *
     * @param  sHost  the server's hostname
     * @param  sPort the server's portnumber
     * @return  the telosobjects sessions were recently started with
     */
    public static String[] getStartingObjects(String sHost, String sPort) {

        return tokenize(
            m_Properties.getProperty(
                KEY_RECENT_STARTINGOBJ + sHost + "/" + sPort));

    } //getStartingObjects


/**
 * Gets the graphical palettes for a certain ConceptBase server.
 *
    * @param  sHost  the server's hostname
     * @param  sPort the server's portnumber
     * @return  the graphical palettes
     */
        public static String[] getGraphicalPalettes(String sHost, String sPort) {
        return tokenize(m_Properties.getProperty(KEY_RECENT_GRAPHPALETTE + sHost + "/" + sPort));
    } //getGraphicalPalettes

    /**
     * Adds a new initial telosobject to the connection specified with sHost and sPort.
     * If there is no such connection yet, one is created
     *
     * @param  sObject  the telosobjects name
     * @param  sHost    the address of the CBserver on which we started with this telosobject
     * @param  sPort    the CBserver's port
     */
    public static void addStartingObject(
        String sObject,
        String sHost,
        String sPort) {
        addProperty(
            KEY_RECENT_STARTINGOBJ + sHost + "/" + sPort,
            sObject);
    }

/**
 * Adds a graphical palette for a certaing cbserver
 *
     * @param  sPalette  the palette's name
     * @param  sHost     the address of the CBserver on which we started with this telosobject
     * @param  sPort     the CBserver's port
     */
    public static void addGraphicalPalette(String sPalette,String sHost,String sPort) {
        addProperty(KEY_RECENT_GRAPHPALETTE + sHost + "/" + sPort,sPalette);
    }

    /**
     * Sets the backgroundcolor of all diagramDesktops
     *
     * @param color the color our diagramDesktops shall have.
     */
    public static void setDDColor(Color color) {

        String sRed = String.valueOf(color.getRed());
        String sGreen = String.valueOf(color.getGreen());
        String sBlue = String.valueOf(color.getBlue());

        m_Properties.setProperty(
            KEY_OPTION_DD_BACKGROUNDCOLOR,
            sRed
                + PROPERTIES_DELIMINATOR
                + sGreen
                + PROPERTIES_DELIMINATOR
                + sBlue);
    }

/**
 * Gets the diagramDesktops' color.
 */
    public static Color getDDColor() {
        String[] sRGB =
            tokenize(
                m_Properties.getProperty(
                    KEY_OPTION_DD_BACKGROUNDCOLOR));
        return new java.awt.Color(
            Integer.parseInt(sRGB[0]),
            Integer.parseInt(sRGB[1]),
            Integer.parseInt(sRGB[2]));
    }

    public static void setTimeout(int milliseconds) {
        m_Properties.setProperty(KEY_OPTION_TIMEOUT,Integer.valueOf(milliseconds).toString());
    }

    public static int getTimeout() {
        return Integer.parseInt(m_Properties.getProperty(KEY_OPTION_TIMEOUT));
    }

    public static void setLPICall(boolean val) {
        if(val)
            m_Properties.setProperty(KEY_OPTION_LPICALL,VALUE_TRUE);
        else
            m_Properties.setProperty(KEY_OPTION_LPICALL,VALUE_FALSE);
    }

    public static boolean getLPICall() {
        String value=m_Properties.getProperty(KEY_OPTION_LPICALL);
        if (value.equals(VALUE_TRUE)) {
            return true;
        } else {
            return false;
        }
    }

    public static void setUseQueryResultWindow(boolean val) {
        if(val)
            m_Properties.setProperty(KEY_OPTION_USE_QUERYRESULTWINDOW,VALUE_TRUE);
        else
            m_Properties.setProperty(KEY_OPTION_USE_QUERYRESULTWINDOW,VALUE_FALSE);
    }

    public static boolean getUseQueryResultWindow() {
        String value=m_Properties.getProperty(KEY_OPTION_USE_QUERYRESULTWINDOW);
        if (value.equals(VALUE_TRUE)) {
            return true;
        } else {
            return false;
        }
    }

    public static void setCallTelosParser(boolean val) {
        if(val)
            m_Properties.setProperty(KEY_OPTION_CALL_TELOSPARSER,VALUE_TRUE);
        else
            m_Properties.setProperty(KEY_OPTION_CALL_TELOSPARSER,VALUE_FALSE);
    }

    public static boolean getCallTelosParser() {
        String value=m_Properties.getProperty(KEY_OPTION_CALL_TELOSPARSER);
        if (value.equals(VALUE_TRUE)) {
            return true;
        } else {
            return false;
        }
    }


    public static void setShowLineNumbers(boolean val) {
        if (val)
            m_Properties.setProperty(KEY_OPTION_SHOW_LINE_NUMBERS,VALUE_TRUE);
        else
            m_Properties.setProperty(KEY_OPTION_SHOW_LINE_NUMBERS,VALUE_FALSE);
    }


    public static boolean getShowLineNumbers() {
        // ShowLineNumbers is a new option that is not contained in old .CBjavaInterface
        // files; hence we protect against NullPointerException
        try {
           String value=m_Properties.getProperty(KEY_OPTION_SHOW_LINE_NUMBERS);
           if (value.equals(VALUE_TRUE)) {
               return true;
           } else {
               return false;
           }
        } catch (Exception e) {
           return false;
        }
    }


    public static void setHasCBIvaBrowserWindows(boolean val) {
        if (val)
            m_Properties.setProperty(KEY_OPTION_BROWSER_WINDOWS,VALUE_TRUE);
        else
            m_Properties.setProperty(KEY_OPTION_BROWSER_WINDOWS,VALUE_FALSE);
    }


    public static boolean hasCBIvaBrowserWindows() {
        // true if CBIva shall show the query and modeule browser windows next to the TelosEditor window
        try {
           String value=m_Properties.getProperty(KEY_OPTION_BROWSER_WINDOWS);
           if (value.equals(VALUE_TRUE)) {
               return true;
           } else {
               return false;
           }
        } catch (Exception e) {
           return false;
        }
    }


    // this setting will be stored in .CBJavaInterface configuration file
    public static void setUIDarkMode(boolean val) {
        if (val)
            m_Properties.setProperty(KEY_OPTION_DARKMODE,VALUE_TRUE);
        else
            m_Properties.setProperty(KEY_OPTION_DARKMODE,VALUE_FALSE);
        bSessionDarkMode = val;
    }

    // this setting only stays valid during the current CBIva/CBGraph session
    public static void setSessionDarkMode(boolean val) {
        bSessionDarkMode = val;
    }

    public static void setSessionDarkMode(String lookandfeel) {
        if (lookandfeel != null)
          bSessionDarkMode = (lookandfeel.contains("Dark"));
    }


    public static boolean hasUIDarkMode() {
        // true if CBIva/CBGraph shall use the dark mode of the Look&Feel (if supported)
       return bSessionDarkMode;
    }




    // NodeLevelAware is specifying whether the behavior of nodes with negative node level
    // should be different from normal nodes. If set to "true" (default), a click on such
    // nodes in CBGraph shall select all contained nodes; see ticket #371
    public static void setNodeLevelAware(boolean val) {
        if (val)
            m_Properties.setProperty(KEY_OPTION_NODELEVEL_AWARE,VALUE_TRUE);
        else
            m_Properties.setProperty(KEY_OPTION_NODELEVEL_AWARE,VALUE_FALSE);
    }


    public static boolean isNodeLevelAware() {
        try {
           String value=m_Properties.getProperty(KEY_OPTION_NODELEVEL_AWARE);
           if (value.equals(VALUE_TRUE)) {
               return true;
           } else {
               return false;
           }
        } catch (Exception e) {
           return true;    // by default true
        }
    }




    public static void setCBIvaSmallfont(String val) {
         m_Properties.setProperty(KEY_OPTION_CBIVA_SMALLFONT,val);
    }

    public static void setCBIvaLargefont(String val) {
         m_Properties.setProperty(KEY_OPTION_CBIVA_LARGEFONT,val);
    }

    public static void setPublicCBserver(String val) {
         m_Properties.setProperty(KEY_OPTION_PUBLIC_CBSERVER,val);
    }

    public static String getPublicCBserver() {
         return m_Properties.getProperty(KEY_OPTION_PUBLIC_CBSERVER);
    }

    public static String getPublicCBserverHost() {
         String response = "localhost"; // default
         try {
           String pubCBserver = m_Properties.getProperty(KEY_OPTION_PUBLIC_CBSERVER);
           if (pubCBserver.contains("/")) {
             String[] parts = pubCBserver.split("/");  // pubCBserver has form like myserver.domain.org/4001
             response = parts[0];
           } else {
            response = pubCBserver;
           }
         } catch (Exception e) {
           // do nothing
         }
         return response;
    }

    public static String getPublicCBserverPort() {
         String response = "4001"; // default
         try {
           String pubCBserver = m_Properties.getProperty(KEY_OPTION_PUBLIC_CBSERVER);
           if (pubCBserver.contains("/")) {
             String[] parts = pubCBserver.split("/");  // pubCBserver has form like myserver.domain.org/4001
             response = parts[1];
           }
         } catch (Exception e) {
           // do nothing
         }
         return response;
    }

   // get the standard module separator
    public static String getModuleSeparator() {
         String response = VALUE_DASH; // default
         try {
           response = m_Properties.getProperty(KEY_OPTION_MODULE_SEPARATOR);
         } catch (Exception e) {
           // do nothing
         }
         return response;
    }

   // get the CBIva small font
    public static float getCBIvaSmallfont() {
         float response = 12f; // default
         try {
           response = Float.parseFloat(m_Properties.getProperty(KEY_OPTION_CBIVA_SMALLFONT));
         } catch (Exception e) {
           // do nothing
         }
         if (response < 1f)
           response = 1f;
         if (response > 64f)
           response = 64f;
         return response;
    }


   // get the CBIva large font
    public static float getCBIvaLargefont() {
         float response = 18f; // default
         try {
           response = Float.parseFloat(m_Properties.getProperty(KEY_OPTION_CBIVA_LARGEFONT));
         } catch (Exception e) {
           // do nothing
         }
         if (response < 1f)
           response = 1f;
         if (response > 64f)
           response = 64f;
         return response;
    }



    // get the module separator used in modpath, e.g. "-" is used in "System-oHome"
    public static String getModuleSeparator(String modpath) {
        if (modpath == null) 
           return getModuleSeparator();
        else if (modpath.indexOf(VALUE_SLASH) > -1) 
           return VALUE_SLASH;
        else if (modpath.indexOf(VALUE_DASH) > -1) 
           return VALUE_DASH;
        else
           return getModuleSeparator();  // the default module separator
    }


    // set the standard module separator by inspecting modpath
    public static void setModuleSeparator(String modpath) {
        if (modpath.indexOf(VALUE_SLASH) > -1) 
           m_Properties.setProperty(KEY_OPTION_MODULE_SEPARATOR,VALUE_SLASH);
        else
           m_Properties.setProperty(KEY_OPTION_MODULE_SEPARATOR,VALUE_DASH);
    }

    // return the other choise for module separator
    public static String otherSep(String sep) {
        if (sep.equals(VALUE_DASH))
           return VALUE_SLASH;
        else
           return VALUE_DASH;
    }



    public static void setLoadModelPath(String path) {
        m_Properties.setProperty(KEY_OPTION_LOADMODELPATH,path);
    }

    public static String getLoadModelPath() {
        return m_Properties.getProperty(KEY_OPTION_LOADMODELPATH);
    }

    public static void setLoadLayoutPath(String path) {
        m_Properties.setProperty(KEY_OPTION_LOADLAYOUTPATH,path);
    }

    public static String getLoadLayoutPath() {
        return m_Properties.getProperty(KEY_OPTION_LOADLAYOUTPATH);
    }

    // nissue #69
    public static void setShowLinkCategory(String category) {
        m_Properties.setProperty(KEY_OPTION_SHOWLINKCATEGORY,category);
    }

    public static String getShowLinkCategory() {
        return m_Properties.getProperty(KEY_OPTION_SHOWLINKCATEGORY);
    }


    public static int getPopupMenuDelay() {
        return Integer.parseInt(m_Properties.getProperty(KEY_OPTION_POPUP_DELAY));
    }

    public static void setPopupMenuDelay(int delayInMilliSeconds) {
        m_Properties.setProperty(KEY_OPTION_POPUP_DELAY,Integer.valueOf(delayInMilliSeconds).toString());
    }

    public static boolean getPopupMenuBlocks() {
        return m_Properties.getProperty(KEY_OPTION_POPUP_BLOCKS).equals(VALUE_TRUE);
    }

    public static void setPopupMenuBlocks(boolean blocks) {
        if(blocks)
            m_Properties.setProperty(KEY_OPTION_POPUP_BLOCKS,VALUE_TRUE);
        else
            m_Properties.setProperty(KEY_OPTION_POPUP_BLOCKS,VALUE_FALSE);
     }

     public static boolean getAutoLayout() {
         return m_Properties.getProperty(KEY_OPTION_AUTO_LAYOUT).equals(VALUE_TRUE);
     }

     public static void setAutoLayout(boolean blocks) {
         if(blocks)
             m_Properties.setProperty(KEY_OPTION_AUTO_LAYOUT,VALUE_TRUE);
         else
             m_Properties.setProperty(KEY_OPTION_AUTO_LAYOUT,VALUE_FALSE);
      }



     // click actions will trigger an active rule associated to a graph type;
     // we want to be able to diable them via the CBGraph options menu
     public static boolean getEnableClickActions() {
         boolean result = true;  // enabled by default
         try {
           result = m_Properties.getProperty(KEY_OPTION_CLICK_ACTIONS).equals(VALUE_TRUE);
         } catch (Exception e) {
           // do nothing
         }
         return result;
     }


     public static void setEnableClickActions(boolean newvalue) {
         if (newvalue)
             m_Properties.setProperty(KEY_OPTION_CLICK_ACTIONS,VALUE_TRUE);
         else
             m_Properties.setProperty(KEY_OPTION_CLICK_ACTIONS,VALUE_FALSE);
      }


     // by default CBGraph can display derived links; but it can be disabled if computation is too expensive
     public static boolean getEnableDerivedLinks() {
         boolean result = true;  // enabled by default
         try {
           result = m_Properties.getProperty(KEY_OPTION_DERIVED_LINKS).equals(VALUE_TRUE);
         } catch (Exception e) {
           // do nothing
         }
         return result;
     }

     public static void setEnableDerivedLinks(boolean newvalue) {
         if (newvalue)
             m_Properties.setProperty(KEY_OPTION_DERIVED_LINKS,VALUE_TRUE);
         else
             m_Properties.setProperty(KEY_OPTION_DERIVED_LINKS,VALUE_FALSE);
      }


    public static Level getDebugLevel() {
        return Level.parse(m_Properties.getProperty(KEY_OPTION_DEBUG_LEVEL));
    }

    public static Properties getProperties() {
        return m_Properties;
    }

    /**
     * Adds a certain property to the properties collection.
     * If there is already a property with the same key, the value is added at the first position to the values belonging to that key.
     *
     * @param key the property's key.
     * @param value the property's value.
     */
    private static void addProperty(String key, String value) {
        String recentValue = m_Properties.getProperty(key);

        if (recentValue == null) {

            m_Properties.setProperty(key, value);

        } else {
            String[] values = tokenize(recentValue);
            if (!contains(values, value)) {
                if (values.length >= PROPERTIES_MAXVALUES) {
                    for (int i = PROPERTIES_MAXVALUES-1;i > 0;i--) {
                        values[i] = values[i-1];
                    }
                    values[0] = value;
                    m_Properties.setProperty(key, deTokenize(values));
                } else {
                    m_Properties.setProperty(key,value + PROPERTIES_DELIMINATOR + recentValue);
                }
            }
        }
    }

    /**
     * appends a certain property to the properties collection.
     * If there is already a property with the same key, the value is appended to the values belonging to that key.
     *
     * @param key the property's key.
     * @param value the property's value.
     */
    private static void appendProperty(String key, String value) {
        String recentValue = m_Properties.getProperty(key);

        if (recentValue == null) {

            m_Properties.setProperty(key, value);

        } else {
            String[] values = tokenize(recentValue);
            if (!contains(values, value)) {
                if (values.length >= PROPERTIES_MAXVALUES) {
                    for (int i = 0;i < PROPERTIES_MAXVALUES-1;i++) {
                        values[i] = values[i+1];
                    }
                    values[PROPERTIES_MAXVALUES-1] = value;
                    m_Properties.setProperty(key, deTokenize(values));
                } else {
                    m_Properties.setProperty(key,recentValue + PROPERTIES_DELIMINATOR + value);
                }
            }
        }
    }

    /**
     * Tells if an array contains a certain value
     */
    private static boolean contains(String[] aValues, String sValue) {

        for (int i = 0; i < aValues.length; i++) {
            if (aValues[i].equals(sValue))
                return true;
        }

        return false;
    }

/**
 * Tokenizes a String according to the deliminator which is defined in GEConfig
 */
    private static String[] tokenize(String value) {
        return tokenize(value, PROPERTIES_DELIMINATOR);
    }

    /**
     * Concatenates a stringarray
     */
    private static String deTokenize(String[] values) {
        if (values.length == 0)
            return "";

        StringBuffer rv = new StringBuffer();
        for (int i = 0; i < values.length; i++) {
            rv.append(PROPERTIES_DELIMINATOR + values[i]);
        }
        return rv.toString();
    }

    /**
     * Tokenizes a String according to a arbitrary deliminator.
     */
    private static String[] tokenize(String value, String deliminator) {

        if (value == null)
            return new String[0];

        StringTokenizer tokenizer = new StringTokenizer(value, deliminator);
        String[] returnVal = new String[tokenizer.countTokens()];

        for (int i = 0; i < returnVal.length; i++) {
            returnVal[i] = tokenizer.nextToken();
        }

        return returnVal;
    }

}//CBConfiguration
