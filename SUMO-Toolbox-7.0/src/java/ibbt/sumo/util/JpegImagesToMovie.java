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
** Revision: $Id: JpegImagesToMovie.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

/*
 * @(#)JpegImagesToMovie.java	1.3 01/03/13
 *
 * Copyright (c) 1999-2001 Sun Microsystems, Inc. All Rights Reserved.
 *
 * Sun grants you ("Licensee") a non-exclusive, royalty free, license to use,
 * modify and redistribute this software in source and binary code form,
 * provided that i) this copyright notice and license appear on all copies of
 * the software; and ii) Licensee does not utilize the software in a manner
 * which is disparaging to Sun.
 *
 * This software is provided "AS IS," without a warranty of any kind. ALL
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY
 * IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR
 * NON-INFRINGEMENT, ARE HEREBY EXCLUDED. SUN AND ITS LICENSORS SHALL NOT BE
 * LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING
 * OR DISTRIBUTING THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN OR ITS
 * LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT,
 * INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER
 * CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF
 * OR INABILITY TO USE SOFTWARE, EVEN IF SUN HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGES.
 *
 * This software is not designed or intended for use in on-line control of
 * aircraft, air traffic, aircraft navigation or aircraft communications; or in
 * the design, construction, operation or maintenance of any nuclear
 * facility. Licensee represents and warrants that it will not use or
 * redistribute the Software for such purposes.
 */

import java.awt.Dimension;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Collections;
import java.util.Iterator;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import javax.media.Buffer;
import javax.media.ConfigureCompleteEvent;
import javax.media.ControllerEvent;
import javax.media.ControllerListener;
import javax.media.DataSink;
import javax.media.EndOfMediaEvent;
import javax.media.Format;
import javax.media.Manager;
import javax.media.MediaLocator;
import javax.media.PrefetchCompleteEvent;
import javax.media.Processor;
import javax.media.RealizeCompleteEvent;
import javax.media.ResourceUnavailableEvent;
import javax.media.Time;
import javax.media.control.TrackControl;
import javax.media.datasink.DataSinkErrorEvent;
import javax.media.datasink.DataSinkEvent;
import javax.media.datasink.DataSinkListener;
import javax.media.datasink.EndOfStreamEvent;
import javax.media.format.VideoFormat;
import javax.media.protocol.ContentDescriptor;
import javax.media.protocol.DataSource;
import javax.media.protocol.FileTypeDescriptor;
import javax.media.protocol.PullBufferDataSource;
import javax.media.protocol.PullBufferStream;

/**
 * This program takes a list of JPEG and/or PNG image files and converts them into
 * a QuickTime movie.
 * 
 * Modified by Dirk Gorissen <dirk.gorissen@ua.ac.be>
 */
public class JpegImagesToMovie implements ControllerListener, DataSinkListener {
	private static Logger logger = Logger.getLogger("ibbt.sumo.util.JpegImagesToMovie");
	
	//Call this method
	public static void createMovie(int width, int height, int frameRate, String outputURL, String dir){
		
		if(Util.isHeadless()){
			logger.warning("Operating in a headless environment, could not create movie");
			return;
		}
		
		File d = new File(dir);
		
		if(!d.exists()){
			logger.severe("Source directory " + dir + " does not exist!");
			return;
		}
		
		Vector<String> extensions = new Vector<String>();
		extensions.add(".jpeg");
		extensions.add(".png");
		extensions.add(".jpg");
		File[] files = d.listFiles(new ExtensionFileFilter(extensions));
		
		if(files == null || files.length == 0){
			logger.warning("No *.jpeg, *.jpg or .png input files found in "
					+ dir + ", unable to create movie");
			return;
		}
		
		Vector<String> inputFiles = new Vector<String>();
		
		for(File f : files){
			/*
			 * Don't use getAbsolutePath, this doesn't work when called from
			 * MatLab with a relative path
			 */ 
			inputFiles.add(f.getPath());
		}
		Collections.sort(inputFiles);
		
		// Generate the output media locators.
		MediaLocator oml;

		if ((oml = createMediaLocator(outputURL)) == null) {
			logger.severe("Cannot build media locator from: " + outputURL);
			return;
		}
		
		JpegImagesToMovie imageToMovie = new JpegImagesToMovie();
		imageToMovie.doIt(width, height, frameRate, inputFiles, oml);
		logger.info("Created movie from " + inputFiles.size() + " images at " + outputURL);
	}

	public static void createMovie(int width, int height, int frameRate, String outputURL, String[] files){
		// Generate the output media locators.
		MediaLocator oml;

		if ((oml = createMediaLocator(outputURL)) == null) {
			logger.severe("Cannot build media locator from: " + outputURL);
			return;
		}
		
		Vector<String> inputFiles = new Vector<String>();
		for(String s : files) {
			inputFiles.add(s);
		}
		JpegImagesToMovie imageToMovie = new JpegImagesToMovie();
		imageToMovie.doIt(width, height, frameRate, inputFiles, oml);
		logger.info("Created movie from " + inputFiles.size() + " images at " + outputURL);
	}
	
	//Test driver
	public static void main(String args[]) {
		int width = 1200;
		int height = 901;
		int frameRate = 1;
//		String dir = "/home/dgorissen/mystuff/school/phd/M3-Toolbox/trunk/src/matlab/output";
//		String outputURL = "/home/dgorissen/mystuff/school/phd/M3-Toolbox/trunk/src/matlab/output/models.mov";
		String dir = "output/2007.12.09_15-39-57-rep1/models_out";
		String outputURL = dir + "/models.mov";
		JpegImagesToMovie.createMovie(width,height,frameRate,outputURL,dir);
	}
	
	public boolean doIt(int width, int height, int frameRate, Vector<String> inFiles,
			MediaLocator outML) {
		ImageDataSource ids = new ImageDataSource(width, height, frameRate,
				inFiles);

		Processor p;

		try {
			logger.fine("- create processor for the image datasource ...");
			p = Manager.createProcessor(ids);
		} catch (Exception e) {
			logger.log(Level.SEVERE,"Cannot create a processor from the data source",e);
			return false;
		}

		p.addControllerListener(this);

		// Put the Processor into configured state so we can set
		// some processing options on the processor.
		p.configure();
		if (!waitForState(p, Processor.Configured)) {
			logger.severe("Failed to configure the processor.");
			p.close();
			return false;
		}

		// Set the output content descriptor to QuickTime. 
		p.setContentDescriptor(new ContentDescriptor(
				FileTypeDescriptor.QUICKTIME));

		// Query for the processor for supported formats.
		// Then set it on the processor.
		TrackControl tcs[] = p.getTrackControls();
		Format f[] = tcs[0].getSupportedFormats();
		if (f == null || f.length <= 0) {
			logger.severe("The mux does not support the input format: "
					+ tcs[0].getFormat());
			p.close();
			return false;
		}

		tcs[0].setFormat(f[0]);

		logger.fine("Setting the track format to: " + f[0]);

		// We are done with programming the processor.  Let's just
		// realize it.
		p.realize();
		if (!waitForState(p, Processor.Realized)) {
			logger.severe("Failed to realize the processor.");
			p.close();
			return false;
		}

		// Now, we'll need to create a DataSink.
		DataSink dsink;
		if ((dsink = createDataSink(p, outML)) == null) {
			logger.severe("Failed to create a DataSink for the given output MediaLocator: "
							+ outML);
			p.close();
			return false;
		}

		dsink.addDataSinkListener(this);
		fileDone = false;

		logger.fine("starting processing...");

		// OK, we can now start the actual transcoding.
		try {
			p.start();
			dsink.start();
		} catch (IOException e) {
			logger.log(Level.SEVERE,"IO error during processing: ",e);
			p.close();
			dsink.close();
			return false;
		}

		// Wait for EndOfStream event.
		waitForFileDone();

		// Cleanup.
		try {
			dsink.close();
		} catch (Exception e) {
		}
		p.removeControllerListener(this);

		logger.fine("...done processing.");

		return true;
	}

	/**
	 * Create the DataSink.
	 */
	DataSink createDataSink(Processor p, MediaLocator outML) {

		DataSource ds;

		if ((ds = p.getDataOutput()) == null) {
			logger.severe("Something is really wrong: the processor does not have an output DataSource");
			return null;
		}

		DataSink dsink;

		try {
			logger.fine("- create DataSink for: " + outML);
			dsink = Manager.createDataSink(ds, outML);
			dsink.open();
		} catch (Exception e) {
			logger.log(Level.SEVERE,"Cannot create the DataSink: " + e.getClass().getName() + " - " + e.getMessage(), e);
			return null;
		}

		return dsink;
	}

	Object waitSync = new Object();

	boolean stateTransitionOK = true;

	/**
	 * Block until the processor has transitioned to the given state.
	 * Return false if the transition failed.
	 */
	boolean waitForState(Processor p, int state) {
		synchronized (waitSync) {
			try {
				while (p.getState() < state && stateTransitionOK)
					waitSync.wait();
			} catch (Exception e) {
			}
		}
		return stateTransitionOK;
	}

	/**
	 * Controller Listener.
	 */
	public void controllerUpdate(ControllerEvent evt) {

		if (evt instanceof ConfigureCompleteEvent
				|| evt instanceof RealizeCompleteEvent
				|| evt instanceof PrefetchCompleteEvent) {
			synchronized (waitSync) {
				stateTransitionOK = true;
				waitSync.notifyAll();
			}
		} else if (evt instanceof ResourceUnavailableEvent) {
			synchronized (waitSync) {
				stateTransitionOK = false;
				waitSync.notifyAll();
			}
		} else if (evt instanceof EndOfMediaEvent) {
			evt.getSourceController().stop();
			evt.getSourceController().close();
		}
	}

	Object waitFileSync = new Object();

	boolean fileDone = false;

	boolean fileSuccess = true;

	/**
	 * Block until file writing is done. 
	 */
	boolean waitForFileDone() {
		synchronized (waitFileSync) {
			try {
				while (!fileDone) {
					waitFileSync.wait();
				}
			} catch (Exception e) {
			}
		}
		return fileSuccess;
	}

	/**
	 * Event handler for the file writer.
	 */
	public void dataSinkUpdate(DataSinkEvent evt) {
		if (evt instanceof EndOfStreamEvent) {
			synchronized (waitFileSync) {
				fileDone = true;
				waitFileSync.notifyAll();
			}
		} else if (evt instanceof DataSinkErrorEvent) {
			synchronized (waitFileSync) {
				fileDone = true;
				fileSuccess = false;
				waitFileSync.notifyAll();
			}
		}
	}

	/**
	 * Create a media locator from the given string.
	 */
	static MediaLocator createMediaLocator(String location) {
		
		if (location.startsWith(File.separator)) {
			// absolute UNIX-like pathname
			location = "file:" + location;
		} else if (location.indexOf(":") == 1) {
			// absolute Windows-like pathname (e.g. D:/work/models.mov)
			location = "file:" + location;
		} else if (!(location.indexOf(":") > 1)) {
			// relative pathname
			// No need to specify absolute path! This wouldn't work when called from MatLab anyway.
			//location =  "file:" + System.getProperty("user.dir")
			//		+ File.separator + location;
			location = "file:" + location;
		}
		
		try {
			return new MediaLocator(new URL(location));
		} catch (MalformedURLException e) {
			// unable to resolve location
		}
		
		return null;
	}

	///////////////////////////////////////////////
	//
	// Inner classes.
	///////////////////////////////////////////////

	/**
	 * A DataSource to read from a list of JPEG image files and
	 * turn that into a stream of JMF buffers.
	 * The DataSource is not seekable or positionable.
	 */
	class ImageDataSource extends PullBufferDataSource {

		ImageSourceStream streams[];

		ImageDataSource(int width, int height, int frameRate, Vector<String> images) {
			streams = new ImageSourceStream[1];
			streams[0] = new ImageSourceStream(width, height, frameRate, images);
		}

		public void setLocator(MediaLocator source) {
		}

		public MediaLocator getLocator() {
			return null;
		}

		/**
		 * Content type is of RAW since we are sending buffers of video
		 * frames without a container format.
		 */
		public String getContentType() {
			return ContentDescriptor.RAW;
		}

		public void connect() {
		}

		public void disconnect() {
		}

		public void start() {
		}

		public void stop() {
		}

		/**
		 * Return the ImageSourceStreams.
		 */
		public PullBufferStream[] getStreams() {
			return streams;
		}

		/**
		 * We could have derived the duration from the number of
		 * frames and frame rate.  But for the purpose of this program,
		 * it's not necessary.
		 */
		public Time getDuration() {
			return DURATION_UNKNOWN;
		}

		public Object[] getControls() {
			return new Object[0];
		}

		public Object getControl(String type) {
			return null;
		}
	}

	/**
	 * The source stream to go along with ImageDataSource.
	 */
	class ImageSourceStream implements PullBufferStream {

		Vector<String> images;

		int width, height;

		VideoFormat format;

		int nextImage = 0; // index of the next image to be read.

		boolean ended = false;

		public ImageSourceStream(int width, int height, int frameRate,
				Vector<String> images) {
			this.width = width;
			this.height = height;
			this.images = images;

			format = new VideoFormat(VideoFormat.JPEG, new Dimension(width,
					height), Format.NOT_SPECIFIED, Format.byteArray,
					(float) frameRate);
		}

		/**
		 * We should never need to block assuming data are read from files.
		 */
		public boolean willReadBlock() {
			return false;
		}

		/**
		 * This is called from the Processor to read a frame worth
		 * of video data.
		 */
		public void read(Buffer buf) throws IOException {

			// Check if we've finished all the frames.
			if (nextImage >= images.size()) {
				// We are done.  Set EndOfMedia.
				logger.fine("Done reading all images.");
				buf.setEOM(true);
				buf.setOffset(0);
				buf.setLength(0);
				ended = true;
				return;
			}

			String imageFile = (String) images.elementAt(nextImage);
			nextImage++;

			logger.fine("  - reading image file: " + imageFile);

			try {
				BufferedImage image = null;
				try {
					image = ImageIO.read(new File(imageFile));
				} catch (IOException e) {
					logger.severe("Unable to read image file: " + e.toString());
					throw e;
				}
				convertToBuffer(buf, image);
			} catch (IOException e) {
				synchronized (waitFileSync) {
					// This is needed to prevent infinite hang at
					// waitForFileDone.
					// There is no point in continuing when an error has
					// occurred here.
					fileDone = true;
					fileSuccess = false;
					waitFileSync.notifyAll();
				}
				throw e;
			}
		}
		
		/**
		 * Convert the image to a JPEG-based buffer.
		 * 
		 * @param buf
		 *            the buffer where the image must be sent to
		 * @param image
		 *            the image to convert into the buffer
		 * @throws IOException
		 */
		private void convertToBuffer(Buffer buf, BufferedImage image)
				throws IOException {
			ByteArrayOutputStream baos = new ByteArrayOutputStream();

			Iterator<ImageWriter> writers = ImageIO
					.getImageWritersByFormatName("jpeg");
			if (writers.hasNext()) {
				ImageWriter writer = writers.next();
				ImageOutputStream ios = ImageIO.createImageOutputStream(baos);

				ImageWriteParam param = writer.getDefaultWriteParam();
				param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
				param.setCompressionQuality((float) 1.0);

				writer.setOutput(ios);
				writer.write(null, new IIOImage(image, null, null), param);
				byte[] data = baos.toByteArray();
				logger.fine("    processed " + data.length + " bytes.");
				buf.setData(data);
				buf.setOffset(0);
				buf.setLength(data.length);
				buf.setFormat(format);
				buf.setFlags(buf.getFlags() | Buffer.FLAG_KEY_FRAME);
			} else {
				logger.severe("Unable to locate a JPEG compressor.");
				throw new IOException("Unable to locate a JPEG compressor.");
			}
		}

		/**
		 * Return the format of each video frame.  That will be JPEG.
		 */
		public Format getFormat() {
			return format;
		}

		public ContentDescriptor getContentDescriptor() {
			return new ContentDescriptor(ContentDescriptor.RAW);
		}

		public long getContentLength() {
			return 0;
		}

		public boolean endOfStream() {
			return ended;
		}

		public Object[] getControls() {
			return new Object[0];
		}

		public Object getControl(String type) {
			return null;
		}
	}

}
