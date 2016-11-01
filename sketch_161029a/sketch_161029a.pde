KalmaanFillter myFillter;
SerialProtocol mySerialClass;

int mouseClickedStep;
float dataMeasured;
float previousDataMeasured;
float dataTop  = 600;
float dataBottom = 0;
float output;
float previousOutput;
PImage graph;
int xPos;
int shift = 2;

void setup()
{
    size(1500,600);
    
    mySerialClass = new SerialProtocol();
 	mySerialClass.serial_init(this,115200);
 	mySerialClass.printEnable = false;

    graph = loadImage("graphBG.png");
    graph.resize(1500,600);
    image(graph,0,0);
    
    myFillter = new KalmaanFillter();
    myFillter.fillter_init(500,200,0,0.00001);
    myFillter.printStatus = false;
    
    dataMeasured = random(dataBottom,dataTop);
}

void draw()
{
	previousDataMeasured = dataMeasured;
	previousOutput = output;	
	output = myFillter.estimated_output(dataMeasured);
	println("input : " + dataMeasured + "   output : " + output);
	mouseClickedStep = 0;
	delay(1);
	graph_plot();
	int bufferSizeTemp = mySerialClass.serial_data_available();
	println("data size :" + bufferSizeTemp );

	if(bufferSizeTemp > 1);
	{
		String read_data = mySerialClass.read_buffer();
		if(read_data.length() > 2)
		{
			String xData = str(read_data.charAt(12));
			xData += str(read_data.charAt(13));
			xData += str(read_data.charAt(14));

			println("datax :" + xData);
			//println("data :" + read_data);

			// textSize(32);
			// text(xData, 50, 30); 
			dataMeasured = parseInt(xData);
		}
	}
}

void keyPressed()
{
	if(key == 'w')
	{
		dataTop = dataTop + 5;
		// dataBottom = dataBottom + 5;
		println("dataTop : " + dataTop);
		println("dataBottom : " + dataBottom);
	}
	else if(key == 's')
	{
		dataTop = dataTop - 5;
		dataBottom = dataBottom - 5;
		println("dataTop : " + dataTop);
		println("dataBottom : " + dataBottom);
	}
	else if(key == 'r')
	{
		dataMeasured = random(dataBottom,dataTop);
	}

}
void mouseClicked()
{
	dataMeasured = random(dataBottom,dataTop);
}
void graph_plot()
{
	strokeWeight(3);
	stroke(255,0,0);
	line( xPos - shift, (int)(previousDataMeasured), xPos, (int)(dataMeasured) );	
	strokeWeight(1);
	stroke(0,255,0);
	line(xPos - shift,(int)(previousOutput) , xPos, (int)(output));
	xPos = xPos + shift;
 	if(xPos > 1500)
 	{
 		xPos = 0;
 		image(graph,0,0);
 	}
}