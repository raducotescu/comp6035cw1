package uk.ac.soton.ecs.rdc1g10.cw1.test;

public class TestClassObjects {
	public static void main(String[] args) throws Exception {
		Object o1 = new Object();
		Thread.sleep(1000);
		Object o2 = new Object();
		/**
		 * unable to run these calls without hacking into the rt.jar runtime
		 * archive and modifying the CLASSPATH to use the bypassed runtime. 
		 */
//		System.out.println(o1.olderThan(o2));
//		System.out.println(o2.olderThan(o1));
	}
}
