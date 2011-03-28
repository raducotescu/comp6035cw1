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

/**
 * This aspect implements a basic class logger as requested in the document from
 * https://secure.ecs.soton.ac.uk/notes/comp6035/cwk1.pdf
 * 
 * @author Radu Cotescu (rdc1g10@ecs.soton.ac.uk)
 */
public aspect FancyLogger {

	/**
	 * Pointcut declaration that intercepts all the calls to the constructors of
	 * @Logging annotated classes, no matter of the containing package
	 */
	pointcut constructor(): call((@(*..Logging) *).new(..));

	/**
	 * Pointcut declaration that intercepts all updates to public members of
	 * 
	 * @Logging annotated classes that happen anywhere outside the constructors
	 *          (i.e. object creation time); it also reaches static members;
	 */
	pointcut publicUpdate(): set(public * (@(*..Logging) *).*)
		&& !withincode((@(*..Logging) *).new(..));

	/**
	 * Pointcut declaration that intercepts all updates to private members of
	 * 
	 * @Logging annotated classes that happen anywhere outside the constructors
	 *          (i.e. object creation time); it also reaches static members;
	 */
	pointcut privateUpdate(): set(private * (@(*..Logging) *).*)
		&& !withincode((@(*..Logging) *).new(..));

	/**
	 * Advice that uses the constructor() pointcut; it instantiates a Date
	 * object right after the constructor successfully created the object and
	 * passes it along with the source file location where a constructor call
	 * has been used, the associated tag and the constructor's arguments to the
	 * private writeEntryToFile method
	 * 
	 * @param o
	 *            The object returned by the intercepted constructor
	 */
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

	/**
	 * Advice that uses the publicUpdate() pointcut; it instantiates a Date
	 * object right after the update was performed and passes it along with the
	 * objectID, source file location where the update call has been performed,
	 * the associated tag and the new value of the field to the private
	 * writeEntryToFile method
	 */
	after() : publicUpdate() {
		Object o = thisJoinPoint.getTarget();
		writeEntryToFile(thisJoinPoint.getSignature().getDeclaringTypeName(),
			/**
			 * In case the update was for a static member o will be null;
			 */
			o == null ? thisJoinPointStaticPart.getSignature()
					.getDeclaringTypeName() + "#static" : getObjectID(o),
			new Date(),
			thisJoinPoint.getSourceLocation().toString(),
			"u(" + thisJoinPoint.getSignature().getName() + ")",
			getArgumentsAsString(thisJoinPoint.getArgs())
		);
	}

	/**
	 * Advice that uses the privateUpdate() pointcut; it instantiates a Date
	 * object right after the update was performed and passes it along with the
	 * objectID, source file location where the update call has been performed,
	 * the associated tag and the new value of the field to the private
	 * writeEntryToFile method
	 */
	after() : privateUpdate() {
		Object o = thisJoinPoint.getTarget();
		writeEntryToFile(
			thisJoinPoint.getSignature().getDeclaringTypeName(),
			/**
			 * In case the update was for a static member o will be null;
			 */
			o == null ? "static" : getObjectID(o),
			new Date(),
			thisJoinPoint.getSourceLocation().toString(),
			"p(" + thisJoinPoint.getSignature().getName() + ")",
			getArgumentsAsString(thisJoinPoint.getArgs())
		);
	}

	/**
	 * Set that holds the primitive wrapper types used to check the arguments
	 * supplied to the advised methods
	 */
	@SuppressWarnings("unchecked")
	private static final Set<Class> WRAPPER_TYPES = new HashSet<Class>(
			Arrays.asList(Boolean.class, Character.class, Byte.class,
					Short.class, Integer.class, Long.class, Float.class,
					Double.class, Void.class));

	/**
	 * Checks if an object is a primitive data type (wrapper type) or not.
	 * 
	 * @param o
	 *            the object to be checked
	 * @return a boolean value containing the truth value of the assumption
	 */
	private static boolean isWrapperType(Object o) {
		return WRAPPER_TYPES.contains(o.getClass());
	}

	/**
	 * Given an Object array it returns a String containing the arguments'
	 * values.
	 * 
	 * @param args
	 *            an Object array holding the arguments of the advised methods
	 * @return a String containing the arguments as value_1;value_2;value_n
	 */
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

	/**
	 * Returns an object's id or value, if the object is a primitive data type.
	 * 
	 * @param o
	 *            the Object to test
	 * @return a String containing the object's id or the primitive data type's
	 *         value
	 */
	private String argumentValue(Object o) {
		if (isWrapperType(o))
			return o.toString();
		else
			return getObjectID(o);
	}

	/**
	 * Returns an object's ID as a String formed from the object's class name +
	 * # + the object's hash code.
	 * 
	 * @param o the object whose ID it's needed
	 * @return a String containing the object's ID
	 */
	private String getObjectID(Object o) {
		return o.getClass().getName() + "#"
				+ new Integer(o.hashCode()).toString();
	}

	/**
	 * For each call writes the CSV entry in a file with the name
	 * ${className}_FancyLogger.csv
	 * 
	 * @param className the name of the class for which the logging is done
	 * @param objectID
	 * @param time the time at which the constructor created the object
	 * @param location the location of the join point
	 * @param tag the associated tag corresponding to the join point's operation
	 * @param arguments the arguments of the join point
	 */
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
