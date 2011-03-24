package uk.ac.soton.ecs.rdc1g10.cw1;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

public aspect FancyLogger {

	pointcut constructor(): call((@(*..Logging) *).new(..));
	pointcut publicUpdate(): set(public * (@(*..Logging) *).*) && !withincode((@(*..Logging) *).new(..));
	pointcut privateUpdate(): set(private * (@(*..Logging) *).*) && !withincode((@(*..Logging) *).new(..));


	after() returning(Object o) : constructor() {
		writeEntryToFile(
				o.getClass().getName(),
				getObjectID(o),
				new Date(),
				thisJoinPoint.getSourceLocation().toString(),
				"n",
				getArgumentsAsString(thisJoinPoint.getArgs())
				);
	}
	
	after() : publicUpdate() {
		Object o = thisJoinPoint.getTarget();
		writeEntryToFile(
				thisJoinPoint.getSignature().getDeclaringTypeName(),
				o == null ? thisJoinPointStaticPart.getSignature().getDeclaringTypeName() + "#static" : getObjectID(o),
				new Date(),
				thisJoinPoint.getSourceLocation().toString(),
				"u(" + thisJoinPoint.getSignature().getName() + ")",
				getArgumentsAsString(thisJoinPoint.getArgs())
				);
	}
	
	after() : privateUpdate() {
		Object o = thisJoinPoint.getTarget();
		writeEntryToFile(
				thisJoinPoint.getSignature().getDeclaringTypeName(),
				o == null ? "static" : getObjectID(o),
				new Date(),
				thisJoinPoint.getSourceLocation().toString(),
				"p(" + thisJoinPoint.getSignature().getName() + ")",
				getArgumentsAsString(thisJoinPoint.getArgs())
				);
	}

	@SuppressWarnings("unchecked")
	private static final Set<Class> WRAPPER_TYPES = new HashSet<Class>(
			Arrays.asList(Boolean.class, Character.class, Byte.class,
					Short.class, Integer.class, Long.class, Float.class,
					Double.class, Void.class));

	public static boolean isWrapperType(Object o) {
		return WRAPPER_TYPES.contains(o.getClass());
	}

	private String getArgumentsAsString(Object[] args) {
		StringBuffer result = new StringBuffer();
		int counter = 0;
		for (Object o : args) {
			result.append(argumentValue(o));
			if (counter++ != args.length - 1) {
				result.append(";");
			}
		}
		return result.toString();
	}

	private String argumentValue(Object o) {
		if (isWrapperType(o))
			return o.toString();
		else
			return getObjectID(o);
	}

	private String getObjectID(Object o) {
		return o.getClass().getName() + "#"
				+ new Integer(o.hashCode()).toString();
	}

	private void writeEntryToFile(String className, String objectID, Date time,
			String location, String tag, String arguments) {
		File file = new File(className + "_FancyLogger.csv");
		BufferedWriter bw = null;
		try {
			FileWriter fw = new FileWriter(file, true);
			bw = new BufferedWriter(fw);
			SimpleDateFormat sdf = new SimpleDateFormat(
					"EEE d MMM yyyy HH:mm:ss.S z");
			bw.write(String.format("%s,%s,%s,%s,%s", objectID,
					sdf.format(time), location, tag, arguments));
			bw.newLine();
		} catch (IOException e) {
			System.err.println("Error: unable to write to file " + className
					+ "_FancyLogger.csv");
		} finally {
			if (bw != null) {
				try {
					bw.close();
				} catch (IOException e) {
					System.err.println("Error: unable to close file "
							+ className + "_FancyLogger.csv");
				}
			}
		}
	}
}
