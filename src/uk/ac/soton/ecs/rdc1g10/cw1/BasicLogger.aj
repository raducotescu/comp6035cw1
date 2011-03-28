package uk.ac.soton.ecs.rdc1g10.cw1;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * This aspect implements a basic class logger as requested in the document
 * from https://secure.ecs.soton.ac.uk/notes/comp6035/cwk1.pdf
 * 
 * @author Radu Cotescu (rdc1g10@ecs.soton.ac.uk)
 */
public aspect BasicLogger {

	/**
	 * Pointcut declaration that intercepts all the calls to the constructors
	 * of @Logging annotated classes, no matter of the containing package 
	 */
	pointcut constructor(): call((@(*..Logging) *).new(..));

	/**
	 * Advice that uses the constructor() pointcut; it instantiates a Date object
	 * right after the constructor successfully created the object and passes
	 * it along with the source file location where a constructor call has been
	 * used to the private writeEntryToFile method
	 * 
	 * @param o The object returned by the intercepted constructor
	 */
	after() returning(Object o) : constructor() {
		String className = o.getClass().getName();
		Date time = new Date();
		String location = thisJoinPoint.getSourceLocation().toString();
		writeEntryToFile(className, time, location);
	}

	/**
	 * For each call writes the CSV entry in a file with the name
	 * ${className}_BasicLogger.csv
	 * 
	 * @param className the name of the class for which the logging is done
	 * @param time the time at which the constructor created the object
	 * @param location the location of the constructor call
	 */
	private void writeEntryToFile(String className, Date time, String location) {
		File file = new File(className + "_BasicLogger.csv");
		BufferedWriter bw = null;
		try {
			FileWriter fw = new FileWriter(file, true);
			bw = new BufferedWriter(fw);
			SimpleDateFormat sdf = new SimpleDateFormat(
					"EEE d MMM yyyy HH:mm:ss.S z");
			bw.write(String.format("%s,%s", sdf.format(time), location));
			bw.newLine();
		} catch (IOException e) {
			System.err.println("Error: unable to write to file " + className
					+ "_BasicLogger.csv");
		} finally {
			if (bw != null) {
				try {
					bw.close();
				} catch (IOException e) {
					System.err.println("Error: unable to close file "
							+ className + "_BasicLogger.csv");
				}
			}
		}
	}
}
