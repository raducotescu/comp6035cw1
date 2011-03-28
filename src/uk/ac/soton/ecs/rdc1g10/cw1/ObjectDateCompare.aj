package uk.ac.soton.ecs.rdc1g10.cw1;

import java.util.Date;
import java.util.HashMap;

/**
 * This aspect adds a boolean olderThan(Object o) method to the Object class, as
 * requested in the document from
 * https://secure.ecs.soton.ac.uk/notes/comp6035/cwk1.pdf
 * 
 * @author Radu Cotescu (rdc1g10@ecs.soton.ac.uk)
 */
public aspect ObjectDateCompare {
	private static HashMap initMap = new HashMap();

	/**
	 * Pointcut descriptor that intercepts the calls to every class'
	 * constructors, except constructor calls from this aspect.
	 */
	pointcut constructor() : call(Object+.new(..)) && !within(ObjectDateCompare);

	/**
	 * Advise that uses the constructor() pointcut; it adds every object to this
	 * aspect's static HashMap initMap along with its creation date, since the
	 * hash map can be used by inter-type declarations.
	 * @param o
	 */
	after() returning(Object o): constructor() {
		initMap.put(o, new Date());
	}

	/**
	 * Checks to see if this object is older than another object.
	 * @param o the object with which the comparison should be made.
	 * @return a boolean value containing the result of the assertion
	 */
	boolean Object.olderThan(Object o) {
		if (((Date) initMap.get(this)).compareTo((Date) initMap.get(o)) < 0)
			return true;
		return false;
	}
}
