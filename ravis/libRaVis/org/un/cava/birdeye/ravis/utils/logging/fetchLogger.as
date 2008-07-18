package org.un.cava.birdeye.ravis.utils.logging
{
	import flash.utils.describeType;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	//Fetches the respective logger for the class classToLog.
	//The method conforms to the convention that the category of
	//a logger is a fully qualified name of a class in question
	public function fetchLogger(classToLog : Class) : ILogger
	{
		return Log.getLogger(describeType(classToLog).@name.toString().replace("::", "."))
	}

}