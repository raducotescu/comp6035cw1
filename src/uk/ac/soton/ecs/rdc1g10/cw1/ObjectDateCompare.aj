package uk.ac.soton.ecs.rdc1g10.cw1;

import java.util.Date;
import java.util.HashMap;

public aspect ObjectDateCompare {
	private static HashMap initMap = new HashMap();

	pointcut constructor() : call(Object+.new(..)) && !within(ObjectDateCompare);

	after() returning(Object o): constructor() {
		initMap.put(o, new Date());
	}

	boolean Object.olderThan(Object o) {
		if (((Date) initMap.get(this)).compareTo((Date) initMap.get(o)) < 0)
			return true;
		return false;
	}
}
