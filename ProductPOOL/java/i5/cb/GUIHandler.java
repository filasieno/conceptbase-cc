/*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.text.DateFormat;
import java.util.*;
import java.util.logging.Handler;
import java.util.logging.LogRecord;

import javax.swing.*;
import javax.swing.table.AbstractTableModel;
import javax.swing.table.TableModel;

/**
 * A handler for logging messages into a JFrame
 */

public class GUIHandler extends Handler implements ActionListener {

    private LogFrame logFrame;
    private LogTableModel logTableModel;
    private Object[] selectedPackages;

    public GUIHandler() {
        logTableModel=new LogTableModel();
        logFrame=new LogFrame(logTableModel,this);
        selectedPackages=null;
    }

    public void close() {
        logFrame.setVisible(false);
        logFrame.dispose();
    }

    public void flush() {
    }

    public boolean isLoggable(LogRecord record) {
        if(selectedPackages!=null) {
            String sClass=record.getSourceClassName();
            for(int i=0;i<selectedPackages.length;i++) {
                if(sClass.startsWith((String) selectedPackages[i]))
                    return true;
            }
        }
        else
            return true;
        return false;
    }

    public void publish(LogRecord lr) {
        if(isLoggable(lr)) {
            lr.getSourceClassName(); // without this statement, class name will be lost
            logTableModel.addLogRecord(lr);
        }
    }

    public void actionPerformed(ActionEvent e) {
        Package[] packages=Package.getPackages();
        Object[] packStrings=new Object[packages.length];
        for(int i=0;i<packages.length;i++)
            packStrings[i]=packages[i].getName();
        java.util.Arrays.sort(packStrings,i5.cb.graph.GEUtil.stringComparator);
        JList jl=new JList(packStrings);
        if(selectedPackages!=null) {
            for(int j=0;j<selectedPackages.length;j++)
                jl.setSelectedValue(selectedPackages[j],false);
        }
        JOptionPane.showMessageDialog(logFrame,new JScrollPane(jl));
        selectedPackages=jl.getSelectedValues();
    }

}

class LogFrame extends JFrame {

    public LogFrame(TableModel tm, GUIHandler gh) {
        JTable table = new JTable(tm);
        table.setPreferredScrollableViewportSize(new java.awt.Dimension(600, 70));

        //Create the scroll pane and add the table to it.
        JScrollPane scrollPane = new JScrollPane(table);

        //Add the scroll pane to this window.
        getContentPane().add(scrollPane, java.awt.BorderLayout.CENTER);

        JButton jbClasses=new JButton("Select Packages");
        jbClasses.addActionListener(gh);
        getContentPane().add(jbClasses,java.awt.BorderLayout.SOUTH);

        setDefaultCloseOperation(javax.swing.WindowConstants.DO_NOTHING_ON_CLOSE);
        pack();
        setVisible(true);

    }

}


class LogTableModel extends AbstractTableModel {

    private List lRecords;
    private String[] columnNames={
        "ID",
        "Level",
        "Class",
        "Method",
        "Message",
        "Parameters",
        "Exception",
        "Time"
    };

    public LogTableModel() {
        lRecords=new ArrayList();
    }

    public void addLogRecord(LogRecord lr) {
        lRecords.add(lr);
        fireTableRowsInserted(lRecords.size(),lRecords.size());
    }

    public String getColumnName(int index) {
        return columnNames[index];
    }

    public int getColumnCount() {
        return columnNames.length;
    }

    public int getRowCount() {
        return lRecords.size();
    }

    public Object getValueAt(int row, int col) {
        LogRecord lr=(LogRecord) lRecords.get(row);
        switch(col) {
            case 0: // ID
                return String.valueOf(lr.getSequenceNumber());
            case 1: // Level
                return lr.getLevel();
            case 2: // Class
                return lr.getSourceClassName();
            case 3: // Method
                return lr.getSourceMethodName();
            case 4: // Message
                return lr.getMessage();
            case 5: // Parameters
                Object[] params=lr.getParameters();
                if(params!=null && params.length>0) {
                    StringBuffer sb=new StringBuffer();
                    for (int i=0;i<params.length;i++) {
                        sb.append(params[i].toString());
                        sb.append(";");
                    }
                    return sb.toString();
                }
                else
                    return "---";
            case 6: // Exception/Throwable
                Throwable t=lr.getThrown();
                if(t!=null)
                    return t.getClass().getName() + ":" + t.getMessage();
                else
                    return "---";
            case 7: // Time
                return DateFormat.getTimeInstance(DateFormat.MEDIUM).format(new Date(lr.getMillis()));
            default:
                return "ERROR";
        }
    }

}
