package uk.ac.soton.ecs.rdc1g10.cw1;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

public aspect BasicLogger {

	pointcut constructor(): call((@(*..Logging) *).new(..));

	after() returning(Object o) : constructor() {
		String className = o.getClass().getName();
		Date time = new Date();
		String location = thisJoinPoint.getSourceLocation().toString();
		writeEntryToFile(className, time, location);
	}

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
