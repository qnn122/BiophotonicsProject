package com.example.quangnguyen.bluetoothconnect;

import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Toast;
import android.widget.ToggleButton;

import com.jjoe64.graphview.GraphView;
import com.jjoe64.graphview.GraphViewSeries;
import com.jjoe64.graphview.LineGraphView;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {


    @Override
    public void onBackPressed() {
        if (Bluetooth.connectedThread != null) Bluetooth.connectedThread.write("Q");
        super.onBackPressed();
    }

    // DEBUGGING
    public static final boolean DEBUG = true;
    public static final String LOG_TAG = "MainActivity";

    // Button
    Button bConnect, bDisconnect, bXminus, bXplus;

    // Toggle Button
    ToggleButton tbLock, tbScroll, tbStream;
    static boolean Lock, AutoScrollX, Stream;

    // Graph init()
    static LinearLayout GraphView;
    static GraphView graphView;
    static GraphViewSeries Series;

    // Graph value
    private static double graph2LastXvalue = 0;
    private static int Xview = 10;

    Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            String s1 = Integer.toString(msg.what);
            switch(msg.what) {
                case Bluetooth.SUCCESS_CONNECT:
                    if (DEBUG) { Log.i(LOG_TAG, "Received SUCCESS MESSSAGE HERE, code:" + s1);}

                    Bluetooth.connectedThread = new Bluetooth.ConnectedThread((BluetoothSocket)msg.obj);
                    Toast.makeText(getApplicationContext(), "Connected!", Toast.LENGTH_LONG).show();

                    String s = "Successfully connected";
                    Bluetooth.connectedThread.start();
                    break;
                case Bluetooth.MESSAGE_READ:
                    byte[] readBuf = (byte[]) msg.obj;
                    String strIncom = new String(readBuf, 0, 5);    // create string from bytes array

                    Log.d("strIncom", strIncom);
                    if (strIncom.indexOf('.') == 2 && strIncom.indexOf('s') == 0) {
                        strIncom = strIncom.replace("s", "");

                        if (isFloatNumber(strIncom)) {
                            Series.appendData(new GraphView.GraphViewData(graph2LastXvalue, Double.parseDouble(strIncom)), AutoScrollX);

                            // X-axis control
                            if (graph2LastXvalue >= Xview && Lock==true) {
                                Series.resetData(new GraphView.GraphViewData[] {});
                                graph2LastXvalue = 0;
                            } else graph2LastXvalue += 0.1;

                            if (Lock == true)
                                graphView.setViewPort(0, Xview);
                            else
                                graphView.setViewPort(graph2LastXvalue - Xview, Xview);

                            //refresh
                            GraphView.removeView(graphView);
                            GraphView.addView(graphView);
                        }
                    }
                    break;
            }
        }

        public boolean isFloatNumber(String num) {
            try {
                Double.parseDouble(num);
            }catch(NumberFormatException nfe) {
                return false;
            }
            return true;
        }
    };



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        //
        requestWindowFeature(Window.FEATURE_NO_TITLE); //hide title
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN); // hide title and status bar
        //
        super.onCreate(savedInstanceState);

        this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);                    // request Landscape
        setContentView(R.layout.activity_main);

        LinearLayout background = (LinearLayout) findViewById(R.id.bg);     // Change background color to BLACK
        background.setBackgroundColor(Color.BLACK);
        init();
        Buttoninit();

    }

    void init() {
        Bluetooth.gethandler(mHandler);

        // Initializing Graphview
        GraphView = (LinearLayout) findViewById(R.id.Graph);

        // Init example series data -----
        Series = new GraphViewSeries("Signal",
                    new GraphViewSeries.GraphViewStyle(Color.YELLOW,2), // Color and thickness of the line
                    new GraphView.GraphViewData[] {new GraphView.GraphViewData(0,0)});
        graphView = new LineGraphView(
                this            // context
                , "Graph");     // heading

        graphView.setViewPort(0, Xview);
        graphView.setScrollable(true);
        graphView.setScalable(true);
        graphView.setShowLegend(true);
        graphView.setLegendAlign(com.jjoe64.graphview.GraphView.LegendAlign.BOTTOM);
        graphView.setManualYAxis(true);
        graphView.setManualYAxisBounds(5, 0);
        graphView.addSeries(Series);    // data
        GraphView.addView(graphView);
    }

    void Buttoninit() {
        /*Buttons*/
        bConnect = (Button) findViewById(R.id.bConnect);
        bConnect.setOnClickListener(this);

        bDisconnect = (Button) findViewById(R.id.bDisconnect);
        bDisconnect.setOnClickListener(this);

        bXminus = (Button) findViewById(R.id.bXminus);
        bXminus.setOnClickListener(this);

        bXplus = (Button) findViewById(R.id.bXplus);
        bXplus.setOnClickListener(this);

        /*Toggle Buttons*/
        tbLock = (ToggleButton) findViewById(R.id.tbLock);
        tbLock.setOnClickListener(this);

        tbScroll = (ToggleButton) findViewById(R.id.tbScroll);
        tbScroll.setOnClickListener(this);

        tbStream = (ToggleButton) findViewById(R.id.tbStream);
        tbStream.setOnClickListener(this);

        Lock = true;
        AutoScrollX = true;
        Stream = false;
    }

    @Override
    public void onClick(View v) {
        switch(v.getId()) {
            case R.id.bConnect:
                startActivity(new Intent("android.intent.action.BT1")); //from manifest file
                break;
            case R.id.bDisconnect:
                Bluetooth.disconnect();
                break;
            case R.id.bXminus:
                if (Xview > 1) Xview--;
                break;
            case R.id.bXplus:
                if (Xview < 30) Xview++;
                break;
            case R.id.tbLock:
                if (tbLock.isChecked()){
                    Lock = true;
                }else {
                    Lock = false;
                }
                break;
            case R.id.tbScroll:
                if (tbScroll.isChecked()){
                     AutoScrollX= true;
                }else {
                    AutoScrollX = false;
                }
                break;
            case R.id.tbStream:
                if (tbStream.isChecked()){
                    if (Bluetooth.connectedThread != null) Bluetooth.connectedThread.write("E");
                }else {
                    if (Bluetooth.connectedThread != null) Bluetooth.connectedThread.write("Q");
                }
                break;
        }
    }

   /* @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }*/
}
