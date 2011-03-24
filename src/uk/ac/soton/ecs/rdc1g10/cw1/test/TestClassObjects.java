package uk.ac.soton.ecs.rdc1g10.cw1.test;

public class TestClassObjects {
	public static void main(String[] args) throws Exception {
		Object o1 = new Object();
		Thread.sleep(1000);
		Object o2 = new Object();
		System.out.println(o1.olderThan(o2));
		System.out.println(o2.olderThan(o1));
	}
}
