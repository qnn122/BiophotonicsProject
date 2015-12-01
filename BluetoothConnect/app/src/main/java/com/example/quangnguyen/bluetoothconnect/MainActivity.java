package com.example.quangnguyen.bluetoothconnect;

import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;

import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.view.Window;
import android.view.WindowManager;

import android.widget.LinearLayout;
import android.widget.Button;
import android.widget.ToggleButton;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    Button bConnect, bDisconnect, bXminus, bXplus;
    ToggleButton tbLock, tbScroll, tbStream;
    static boolean Lock, AutoScroll, Stream;

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
