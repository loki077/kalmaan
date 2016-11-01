import processing.serial.*;
/* data packet for understanding
    <:~>                <06>             <lokesh>    <~>
    <start 2 bytes>     <data size>     <data>      <stop byte>

    output: ":~6lokesh~"
*/
class SerialProtocol
{
    Serial myPort;
    
    int initStatus = 0;

    boolean printEnable = true;
    
    int bufferSize = 0;
    int bufferMaxSize = 250;
    String[] buffer = new String[255];
    
    String inBuffer = "";
    String finalData = "";

    int startPointer;
    int stringLength = 0;
    int dataSize;
    
    int writePointer = 0;
    int readPointer = 0;

    boolean serial_init(PApplet parent, int baudRate)
    {
        if(initStatus == 0)
        {
            String portName = Serial.list()[0];
            myPort = new Serial(parent, portName, baudRate);
            if(printEnable)
            {
                println("serial port initialized Auto");
                println("PortName: " + portName );
                println("baudRate: " + baudRate );
            }
            initStatus = 1;
            return true;
        }
        else
        {
            if(printEnable)
            {            
                println("Error : serial port Already initialized Auto");
            }
            return false;
        }
    }

    boolean serial_init(PApplet parent, String portName, int baudRate)
    {
        if(initStatus == 0)
        {
            myPort = new Serial(parent, portName, baudRate);
            if(printEnable)
            {
                println("serial port initialized");
                println("PortName: " + portName );
                println("baudRate: " + baudRate );
            }
            initStatus = 1;
            return true;
        }
        else
        {
            if(printEnable)
            {            
                println("Error : serial port Already initialized");
            }
            return false;
        }
    }
    
    int get_bufferSize()
    {
        int difference;
        if( writePointer >= readPointer)
        {
            difference = writePointer - readPointer; 
        }
        else
        {
            difference = bufferMaxSize - readPointer; 
            difference = difference + writePointer; 
        }
        return difference;
    }

    String read_buffer()
    {
        if(get_bufferSize() > 0)
        {
            String readData = buffer[readPointer];
            readPointer++;
            if(readPointer > bufferMaxSize)
            {
                readPointer = 0;
            }
            return readData;
        }
        else
        {
            if(printEnable)
            {
                println("Serial Error: buffer full"); 
            }
            return "";
        }
    }

    int write_buffer(String tempData)
    {
        if(get_bufferSize() < (bufferMaxSize + 1))
        {
            buffer[writePointer] = tempData;
            writePointer++;
            if(writePointer > bufferMaxSize)
            {
                writePointer = 0;
            }
            return 1;
        }
        else
        {
            return 0;
        }
    }

    int serial_data_available()
    {
        int searchLocation = 0;
        if ( myPort.available() > 0)  //if data available in port go in
        {
            inBuffer += myPort.readString();; 
            stringLength = inBuffer.length();
            if(printEnable)
            {
                println("Serial : Start decoding with this string"); 
                println("Data : " + inBuffer );
            }
            for(int i = 1; i < stringLength + 1; i++)                   //search for start bit until string is finished
            {
                startPointer = inBuffer.indexOf(":",searchLocation);
                if(startPointer > -1)                                 //if start bit found
                {
                    startPointer++;
                    if((startPointer) == stringLength)            //if data finished before getting 2nd start bit
                    {
                        if(printEnable)
                        {
                            println("Serial : startBit1 found but packet finished"); 
                            println("Data : " + inBuffer );
                        }
                        inBuffer = ":";
                        return get_bufferSize();
                    }
                    else                                        //if data not finished
                    {
                        char startBit2 = inBuffer.charAt(startPointer);
                        if(startBit2 == '~')                    //if 2nd start bit found
                        {
                            startPointer++;
                            if((startPointer) == stringLength) //if data finished before getting 2nd start bit
                            {
                                if(printEnable)
                                {
                                    println("Serial : startBit2 found but packet finished"); 
                                    println("Data : " + inBuffer );
                                }
                                inBuffer = ":~";
                                return get_bufferSize();
                            }
                            else                                //if data not finished
                            {
                                String dataSizeTemp = (str(inBuffer.charAt(startPointer)));
                                startPointer++;
                                if((startPointer) == stringLength) //if data finished before getting 2nd start bit
                                {
                                    if(printEnable)
                                    {
                                        println("Serial : size first char found but packet finished"); 
                                        println("Data : " + inBuffer );
                                    }
                                    inBuffer = ":~";
                                    inBuffer += dataSizeTemp;
                                    return get_bufferSize();
                                }
                                else
                                {
                                    dataSizeTemp += (str(inBuffer.charAt(startPointer)));
                                    dataSize = parseInt(dataSizeTemp);
                                    startPointer++;
                                    if(dataSize == 0)
                                    {
                                        if((startPointer) == stringLength) //if data finished before getting 2nd start bit
                                        {
                                            if(printEnable)
                                            {
                                                println("Serial error: datasize is wrong and data got empty"); 
                                                println("Data : " + inBuffer );
                                            }
                                            inBuffer = "";
                                            return get_bufferSize();
                                        }
                                        else
                                        {
                                            if(printEnable)
                                            {
                                                println("Serial error: datasize is wrong "); 
                                                println("Data : " + inBuffer );
                                            }
                                            searchLocation = startPointer;
                                            i = startPointer - 1;
                                        }
                                    }
                                    else if(dataSize >=  (stringLength - startPointer)) //if left data is small than data size
                                    {
                                        String tempBuffer = ":~";
                                        if(dataSize < 10)
                                        {
                                            tempBuffer += "0";
                                            tempBuffer += str(dataSize);
                                        }
                                        else
                                        {
                                            tempBuffer += str(dataSize);
                                        }
                                        for(int z = startPointer; z < stringLength; z++)
                                        {
                                            tempBuffer = tempBuffer + str(inBuffer.charAt(z));
                                        }
                                        inBuffer = tempBuffer;
                                        if(printEnable)
                                        {
                                            println("Serial : data found but packet finished before STOP_BIT"); 
                                            println("Data : " + inBuffer );
                                        }
                                        return get_bufferSize();
                                    }
                                    else                                //if data not finished
                                    {
                                        char stopBit = inBuffer.charAt(startPointer + dataSize);
                                        if(stopBit == '~')    
                                        {
                                            finalData = "";
                                            for(int z = startPointer; z < (startPointer + dataSize) ; z++)
                                            {
                                                finalData = finalData + str(inBuffer.charAt(z));
                                            }
                                            if(write_buffer(finalData) == 1)
                                            {
                                                if(printEnable)
                                                {
                                                    println("Serial : Data stored"); 
                                                    println("Data : " + finalData );
                                                }
                                            }
                                            else
                                            {
                                                if(printEnable)
                                                {
                                                    println("Serial Error: buffer full"); 
                                                }
                                                return get_bufferSize();
                                            }

                                            
                                            searchLocation = startPointer;
                                            i = startPointer - 1;
                                        }
                                        else
                                        {
                                            if(printEnable)
                                            {
                                                println("Serial : Didnt found stop bit"); 
                                                println("Data : " + finalData );
                                            }
                                            searchLocation = startPointer;
                                            i = startPointer - 1;
                                        }
                                    }
                                }
                            }
                        }
                        else                                    //if no 2ndstart bit found
                        {
                            searchLocation = startPointer;
                            i = startPointer - 1;
                        }
                    }
                }
                else    //if no start bit found
                {
                    if(printEnable)
                    {
                        println("Serial Error : Garbage packet"); 
                        println("Data : " + inBuffer );
                    }
                    inBuffer = "";
                    return get_bufferSize();
                }
            }
        }
        else //if data not available in port do nothing
        {
            if(printEnable)
            {
                println("Serial : No data Receive"); 
            }
            return get_bufferSize();
        }
        return get_bufferSize();
    }

    void clear_buffer()
    {
        writePointer = 0;
        readPointer = 0;
    }

    boolean set_buffer_size(int sizeOfDataBuffer)
    {
        if(sizeOfDataBuffer < 255)
        {
            bufferMaxSize = sizeOfDataBuffer;
            return true;
        }
        else
        {
            return false;
        }
    }
}



 