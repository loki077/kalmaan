class KalmaanFillter
{
	float gain;
	float gainPrevious;
	float gainRatio;
	float errorFunction;
	float errorSensor;
	float previousEstimation;
	boolean status;
	boolean printStatus = true;

	boolean fillter_init(float errorSensorTemp, float errorFunctionTemp, float previousEstimationTemp, float gainRatioTemp)
	{
		if(status == false)
		{
			errorFunction = errorFunctionTemp;
			errorSensor = errorSensorTemp;
			previousEstimation = previousEstimationTemp;
			gainRatio = gainRatioTemp;
			status = true;
			if(printStatus)
			{
				println("KalmaanFillter : fillter is init ");
				println("KalmaanFillter : errorFunction = " + errorFunction + "errorSensor = " + errorSensor + "previousEstimation = " + previousEstimation);
			}
			return true;
		}
		else
		{
			if(printStatus)
			{
				println("KalmaanFillter Error: cant be reinitialized");
			}
			return false;
		}
	}

	void gain_update()
	{
		if(status == true)
		{
			float gainTemp = errorFunction / ( errorFunction + errorSensor);
			if(printStatus)
			{
				println("gainTemp : "+  gainTemp);
			}
			//gain = gainTemp;
			if(gainTemp >= gainPrevious)
			{
				if(printStatus)
				{
					println("gainTemp >= gainPrevious");
				}
				if((gainTemp - gainPrevious) > gainRatio)
				{
					gain = gain + gainRatio;
				}
				else
				{
					gain = gainTemp;
				}
			}
			else
			{
				if(printStatus)
				{
					println("gainTemp < gainPrevious");
				}
				if((gainPrevious - gainTemp) > gainRatio)
				{
					gain = gain - gainRatio;
				}
				else
				{ 
					gain = gainTemp;
				}
			}
			if(printStatus)
			{
				println("gain : "+  gain);
			}
			gainPrevious = gain;
		}
		else
		{
			if(printStatus)
			{
				println("KalmaanFillter Error: system not init()");
			}
		}
	}

	float estimated_output(float measuredValue)
	{
		if(status == true)
		{
			gain_update();
			float estimatedOutput = previousEstimation + (gain * ( measuredValue - previousEstimation));
			error_function_update();
			previousEstimation = estimatedOutput;
			if(printStatus)
			{
				println("KalmaanFillter : data out");
				println("KalmaanFillter : previousEstimation = " + previousEstimation);
				println("KalmaanFillter : estimatedOutput = " + estimatedOutput);
				println("KalmaanFillter : errorFunction = " + errorFunction);
			}
			return estimatedOutput;
		}
		else
		{
			if(printStatus)
			{
				println("KalmaanFillter Error: system not init()");
			}
			return 0;
		}

	}

	void error_function_update()
	{
		errorFunction = (1 - gain) * (previousEstimation);
	}
}