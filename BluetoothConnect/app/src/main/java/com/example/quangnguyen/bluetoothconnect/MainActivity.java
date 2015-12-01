package com.example.quangnguyen.bluetoothconnect;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ToggleButton;

import com.jjoe64.graphview.GraphView;
import com.jjoe64.graphview.GraphViewSeries;
import com.jjoe64.graphview.LineGraphView;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    Button bConnect, bDisconnect, bXminus, bXplus;
    ToggleButton tbLock, tbScroll, tbStream;
    static boolean Lock, AutoScroll, Stream;
    // Graph init()
    static LinearLayout GraphView;
    static GraphView graphView;
    static GraphViewSeries Series;
    private static double graph2LastXvalue = 0;
    private static int Xview = 10;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);                    // request Lanscape
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN); // hide title and status bar
        setContentView(R.layout.activity_main);

        LinearLayout background = (LinearLayout) findViewById(R.id.bg);     // Change background color to BLACK
        background.setBackgroundColor(Color.BLACK);
        init();
        Buttoninit();

    }

    void init() {
        GraphView = (LinearLayout) findViewById(R.id.Graph);
        Series = new GraphViewSeries("Signal",
                    new GraphViewSeries.GraphViewStyle(Color.YELLOW,2),
                    new GraphView.GraphViewData[] {new GraphView.GraphViewData(0,0)});
        graphView = new LineGraphView(this, "Graph");

        graphView.setViewPort(0, Xview);
        graphView.setScrollable(true);
        graphView.setScalable(true);
        graphView.setShowLegend(true);
        graphView.setLegendAlign(com.jjoe64.graphview.GraphView.LegendAlign.BOTTOM);
        graphView.setManualYAxis(true);
        graphView.setManualYAxisBounds(5, 0);
        graphView.addSeries(Series);
        graphView.addView(graphView);
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
        AutoScroll = true;
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

                break;
            case R.id.bXplus:

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
                     AutoScroll= true;
                }else {
                    AutoScroll = false;
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

    @Override
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
    }
}
