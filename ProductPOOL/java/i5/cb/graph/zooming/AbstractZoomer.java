/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
/*
 * Created on 2005-1-1
 * 
 * Copyright 2005 by Li Xiang,
 *
 * All rights reserved.
 * 
 */
package i5.cb.graph.zooming;
import java.awt.*;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.util.Hashtable;

import javax.swing.*;

/**
 * Description: AbstactZoomer provide routines zooming 
 * ordinary java components including containers and Images.
 *
 * @author Li Xiang
 * 
 * @version 1.0
 */
public class AbstractZoomer implements Zoomer {

	
	public AbstractZoomer() {
		factor = 1 ;
		oldFactor = 1;
		componentSizes = new Hashtable(100);
	}

	/*
	 * this method is used to zoom the size of a single component
	 * according to the zooming factor. recursivity is not taken 
	 * into account here.
	 */
	public void zoomSize(Component c){
		//first deal with the area
		Dimension oldSize = this.getComponentOriginalSize(c).getSize();
		Rectangle origBound = c.getBounds();
		Rectangle b = new Rectangle(0,0,oldSize.height,oldSize.width);
		b.height *= factor;
		b.width *= factor;
		int centerX=origBound.x+origBound.width/2;
		int centerY=origBound.y+origBound.height/2;
		b.x=centerX-b.width/2;
		b.y=centerY-b.height/2;
		c.setBounds(b);
               c.setPreferredSize(b.getSize()); // need to adapt the size of the component c itself (here a DiagramLabel.
		//adapt the font size to the zoomed component
		Font origFont  = this.getComponentOriginalSize(c).getFont();
		c.setFont(new Font(origFont.getName(),origFont.getStyle(),(int)(origFont.getSize()*factor)));
	}



	
	/* According to our zooming strategy, translate comonents
	 * farther away from the left upper corner.recursivity is 
	 * not taken into account here. 
	 */
	private void translate(Component c){
		//Rectangle origBound = this.getComponentOriginalSize(c).getBounds(),
		Rectangle origBound = c.getBounds();
		Rectangle b = new Rectangle();
		//	keep size unchanged
		b.height= origBound.height;
		b.width = origBound.width;
		//keep center unchanged
		int centerX=origBound.x+origBound.width/2;
		int centerY=origBound.y+origBound.height/2;		
		b.x = (int)(centerX*factor/oldFactor)-origBound.width/2;
		b.y = (int)(centerY*factor/oldFactor)-origBound.height/2;
		
		c.setBounds(b);
			
	}
	/**
	 * Description: auxiliary method to zoom component 
	 * 			without taking into account recursivity
	 * @param c the component to be zoomed
	 * @author Li Xiang
	 */
	private void zoom_aux(Component c){
		translate(c);
		zoomSize(c);
	}
	
	private void zoomChildren(Container c){
		if(c==null||c instanceof JTree)
			return;
		else{
			Component [] children =c.getComponents();
			for(int i=0;i<children.length;i++){
				zoom(children[i]);
			}
		}
	}
	
	private void zoomContainerImage(Container c){
		if(c instanceof JLabel){
			ImageHashtableEntry entry=getComponentOriginalImage(c);
			if(entry!=null){
				BufferedImage bimg=ImageUtil.toBufferedImage(entry.getImg());
				AffineTransform tx = new AffineTransform();
			    tx.scale(factor,factor);
			    AffineTransformOp op = new AffineTransformOp(tx, AffineTransformOp.TYPE_BILINEAR);
			    bimg = op.filter(bimg, null);
			    ((JLabel)c).setIcon(new ImageIcon(Toolkit.getDefaultToolkit().createImage(bimg.getSource())));
			}
		}else if(c instanceof JButton){
			ImageHashtableEntry entry=getComponentOriginalImage(c);
			if(entry!=null){
				BufferedImage bimg=ImageUtil.toBufferedImage(entry.getImg());
				AffineTransform tx = new AffineTransform();
			    tx.scale(factor,factor);
			    AffineTransformOp op = new AffineTransformOp(tx, AffineTransformOp.TYPE_BILINEAR);
			    bimg = op.filter(bimg, null);
			    ((JButton)c).setIcon(new ImageIcon(Toolkit.getDefaultToolkit().createImage(bimg.getSource())));
			}
		}else
			return;
	}
	
	private void zoomContainer(Container c){
		if(c==null)
			return;
		zoomChildren(c);
		zoomContainerImage(c);
	}
	
	/* Two methods of zooming is provided here.To Let a new component
	 * take charge of itself is recommended according to responsibility-driven design. 
	 * However we also provide here a solution to deal with "plain" component in this
	 * method.
	 */
	public void zoom(Component c){
		if(oldFactor==factor)
			return;
		if(c instanceof Zoomable){
			((Zoomable)c).setZoom(factor);
		}
		else{
			if(c instanceof Container)
				zoomContainer((Container)c);
			zoom_aux(c);
			c.repaint();
		}
	}
	
	/**
	 * @return Returns the zooming factor.
	 */
	public float getFactor() {
		return factor;
	}
	
	/**
	 * @param factor The zooming factor to set.
	 */
	public void setFactor(float factor) {
		oldFactor = this.factor;
		this.factor = factor;
	}

	/**
	 * @param factor The zooming factor to restore.
	 */
	public void restoreFactor(float factor) {
		oldFactor = factor;
		this.factor = factor;
	}
	
	/**
	 * this method first try to look up the size info of a component in the 
	 * Hashtable and return it. If failed, then create a new entry with the 
	 * current info of this component and return it.
	 * 
	 * @param c a component
	 * @return a <code>SizeHashTableEntry</code> 
	 */
	protected SizeHashtableEntry getComponentOriginalSize(Component c){
		SizeHashtableEntry size = (SizeHashtableEntry)componentSizes.get(c);
		if(size == null){
			size = new SizeHashtableEntry(c.getBounds(),c.getFont());
			componentSizes.put(c,size);
		}
		return size; 
	}
	
	/**
	 * record the current size info of component into hashtable
	 * @param c the component to be recorded
	 */
	protected void recordComponentSize(Component c){
		SizeHashtableEntry size = new SizeHashtableEntry(c.getBounds(),c.getFont());
		componentSizes.put(c,size);		
	}


        /**
         * Updates the size for a specific component. Issue #79 
         */
        public void updateComponentSize(Component c, Dimension newdim) {
            SizeHashtableEntry entry = (SizeHashtableEntry)componentSizes.get(c);
            if (entry != null) {
                entry.size = new Dimension(newdim.height, newdim.width);
            }
        }
	
	protected ImageHashtableEntry getComponentOriginalImage(Component c){
		if(imageTable == null)
			imageTable = new Hashtable(20);
		ImageHashtableEntry entry = (ImageHashtableEntry)imageTable.get(c);
		if(entry == null){
			if(c instanceof JLabel){
				Icon icon=((JLabel)c).getIcon();
				if(icon instanceof ImageIcon){
					Image img=((ImageIcon)icon).getImage();
					entry = new ImageHashtableEntry(img);
					imageTable.put(c,entry);
				}
			}else if(c instanceof JButton){
				Icon icon=((JButton)c).getIcon();
				if(icon instanceof ImageIcon){
					Image img=((ImageIcon)icon).getImage();
					entry = new ImageHashtableEntry(img);
					imageTable.put(c,entry);
				}
			}
		}
		return entry; 
	}
	
	protected void recordComponentImage(Component c,Image img){
		if(imageTable == null)
			imageTable = new Hashtable(20);
		ImageHashtableEntry entry = new ImageHashtableEntry(img);
		imageTable.put(c,entry);
	}
	
	/**
	 * current zooming factor, initially set to 1.
	 */
	protected float factor;//,oldFactor;
	
	/**
	 * this table is used to record images, especially those contained in 
	 * JLabel,JButton,etc.
	 */
	protected Hashtable imageTable;
	
	/**
	 * Hashtable used to store the original size info of all components.
	 * The info will be recorded when components first call the zoom method
	 */
	protected Hashtable componentSizes;
	
	protected float oldFactor;
	
	protected class ImageHashtableEntry{
		/**
		 * @param img
		 */
		public ImageHashtableEntry(Image img) {
			super();
			this.img = img;
		}
		/**
		 * @return Returns the img.
		 */
		public Image getImg() {
			return img;
		}
		/**
		 * @param img The img to set.
		 */
		public void setImg(Image img) {
			this.img = img;
		}
		
		private ImageHashtableEntry() {}
		
		Image img;
		
	}
	/**
	 * 
	 * SizeHashtableEntry represent the entry used in the Hashtable recording the original size
	 * info of components.
	 * 
	 * @author lixiang
	 *
	 */
	protected class SizeHashtableEntry{
		
		private SizeHashtableEntry(){}
		/**
		 * @param bounds the original bounds of component
		 * @param font the original font of component
		 */
		public SizeHashtableEntry(Rectangle bounds, Font font) {
			super();
			size = new Dimension(bounds.height,bounds.width);
			this.font = font;
		}
		
		protected Dimension size;
		
		protected Font font;
		
		/**
		 * @return Returns the bounds.
		 */
		public Dimension getSize() {
			return size;
		}
		
		/**
		 * @return Returns the font.
		 */
		public Font getFont() {
			return font;
		}
		/**
		 * @param font The font to set.
		 */
		public void setFont(Font font) {
			this.font = font;
		}
	}
	
	
}
