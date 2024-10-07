using Godot;
using Godot.NativeInterop;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;

namespace OSFHandlerNode
{
public partial class OSFHandler : Node
{
    public ushort listenPort=11572;
    public string listenHost="127.0.0.1";
    /// <summary>
    /// because openseeface is a separate program and we just act as the server it talks with
    /// </summary>
    private UdpServer udpServerComponent;


    public bool started=false;
    /// <summary>
    /// the number of points used in the tracker.
    /// shouldn't need changed at all.
    /// </summary>
    public int points=68;
    /// <summary>
    /// the important object.
    /// this thing is managing the data and interpolation+calibration
    /// for the data before it gets used.
    /// </summary>
    public OSFDataInfo _dataInfo;
    
    /// <summary>
    /// emitted whenever a new update from the tracker is received and processed, with the updated data package as the parameter
    /// </summary>
    [Signal]
    public delegate void onDataPackageEventHandler();
    

    public Godot.Collections.Dictionary dataPackage=new Godot.Collections.Dictionary();

    public Godot.Collections.Dictionary getPackage(){return dataPackage;}

    public override void _Ready(){
        this.started=false;
        
        // this._dataInfo=(RefCounted)GetParent().Call("BuildDataInfo");
        this._dataInfo=new OSFDataInfo();
        this._dataInfo.Call("ConnectInfoToSignal",this);
        this._dataInfo.Call("BuildDataInfo");
        BuildDataPackage();




    }
    /// <summary>
    /// exists because it hates me otherwise when i try to initialize it normally
    /// </summary>
    private void BuildDataPackage(){
        dataPackage.Add("time",-1);
        dataPackage.Add("id",-1);
        
        Godot.Collections.Dictionary cam= new Godot.Collections.Dictionary();
        cam.Add("x",-1);
        cam.Add("y",-1);
        dataPackage.Add("cam",cam);
        
        dataPackage.Add("rightEyeOpen",-1);
        dataPackage.Add("leftEyeOpen",-1);
        dataPackage.Add("3d",-1);
        dataPackage.Add("fitError",-1);
        
        Godot.Collections.Dictionary quaternion=new Godot.Collections.Dictionary();
        quaternion.Add("x",-1);
        quaternion.Add("y",-1);
        quaternion.Add("z",-1);
        quaternion.Add("w",-1);
        dataPackage.Add("quaternion",quaternion);

        Godot.Collections.Dictionary euler=new Godot.Collections.Dictionary();
        euler.Add("x",-1);
        euler.Add("y",-1);
        euler.Add("z",-1);
        dataPackage.Add("euler",euler);

        Godot.Collections.Dictionary translation=new Godot.Collections.Dictionary();
        translation.Add("x",-1);
        translation.Add("y",-1);
        translation.Add("z",-1);
        dataPackage.Add("translation",translation);

        dataPackage.Add("confidence",new Godot.Collections.Array());
        dataPackage.Add("points",new Godot.Collections.Array());
        dataPackage.Add("points3D",new Godot.Collections.Array());
        ((Godot.Collections.Array)dataPackage["confidence"]).Resize(points);
        ((Godot.Collections.Array)dataPackage["points"]).Resize(points);
        ((Godot.Collections.Array)dataPackage["points3D"]).Resize(points+2);
        //((Godot.Collections.Array)dataPackage["points"]).Resize(points);
        Godot.Collections.Dictionary features=new Godot.Collections.Dictionary();
        features.Add("EyeLeft",-1);
        features.Add("EyeRight",-1);
        features.Add("EyeBrowSteepnessLeft",-1);
        features.Add("EyeBrowSteepnessRight",-1);
        features.Add("EyeBrowUpDownLeft",-1);
        features.Add("EyeBrowUpDownRight",-1);
        features.Add("EyeBrowQuirkLeft",-1);
        features.Add("EyeBrowQuirkRight",-1);
        features.Add("MouthCornerUpDownLeft",-1);
        features.Add("MouthCornerUpDownRight",-1);
        features.Add("MouthCornerInOutLeft",-1);
        features.Add("MouthCornerInOutRight",-1);
        features.Add("MouthOpen",-1);
        features.Add("MouthWide",-1);
        features.Add("3DPoints",new Godot.Collections.Array<Vector3>());
        features.Add("2DPoints",new Godot.Collections.Array<Vector2>());
        dataPackage.Add("features",features);
        
    }


    public void startServer(){
        if(udpServerComponent==null){
		    udpServerComponent = new Godot.UdpServer();
		    Godot.Error _err = udpServerComponent.Listen(listenPort,listenHost);
            GD.Print("opened UDP server: "+listenHost.ToString()+":"+listenPort.ToString());
        }
        started = true;
    }
    public override void _Process(double delta)
    {
        if(_dataInfo!=null) _dataInfo._update_features((float)delta);
    }

    public override void _PhysicsProcess(double delta)
    {
        if(!started) return;

        Godot.Error _poll=udpServerComponent.Poll();

        if(udpServerComponent.IsConnectionAvailable()){
            PacketPeerUdp conn = udpServerComponent.TakeConnection();
            byte[] data = conn.GetPacket();
            conn.Close();

            Stream stream = new MemoryStream(data);
            BinaryReader reader = new BinaryReader(stream);

            dataPackage["time"] = reader.ReadDouble();

            dataPackage["id"] = reader.ReadInt32();

            ((Godot.Collections.Dictionary)dataPackage["cam"])["x"]=reader.ReadSingle();
            ((Godot.Collections.Dictionary)dataPackage["cam"])["y"]=reader.ReadSingle();

            dataPackage["rightEyeOpen"]=reader.ReadSingle();
            dataPackage["leftEyeOpen"]=reader.ReadSingle();
            dataPackage["3d"]=reader.ReadBoolean();

            dataPackage["fitError"]=reader.ReadSingle();

            ((Godot.Collections.Dictionary)dataPackage["quaternion"])["x"]=reader.ReadSingle();
            ((Godot.Collections.Dictionary)dataPackage["quaternion"])["y"]=reader.ReadSingle();
            ((Godot.Collections.Dictionary)dataPackage["quaternion"])["z"]=reader.ReadSingle();
            ((Godot.Collections.Dictionary)dataPackage["quaternion"])["w"]=reader.ReadSingle();
            
            ((Godot.Collections.Dictionary)dataPackage["euler"])["x"]=Mathf.DegToRad(reader.ReadSingle());
            ((Godot.Collections.Dictionary)dataPackage["euler"])["y"]=Mathf.DegToRad(reader.ReadSingle());
            ((Godot.Collections.Dictionary)dataPackage["euler"])["z"]=Mathf.DegToRad(reader.ReadSingle());

            ((Godot.Collections.Dictionary)dataPackage["translation"])["x"]=reader.ReadSingle();
            ((Godot.Collections.Dictionary)dataPackage["translation"])["y"]=reader.ReadSingle();
            ((Godot.Collections.Dictionary)dataPackage["translation"])["z"]=reader.ReadSingle();
            //for confidence. i dont care about this right now, but i need to have it i guess
            for(int _i=0;_i<points;_i++){
                ((Godot.Collections.Array)dataPackage["confidence"])[_i]=reader.ReadSingle();
            }
            for(int _i=0;_i<points;_i++){
                float a=reader.ReadSingle();
                float b = reader.ReadSingle();
                Vector2 v = new Vector2(a,b);
                ((Godot.Collections.Array)dataPackage["points"])[_i]=v;
            }

            for(int _i=0;_i<points+2;_i++){
                float a=reader.ReadSingle();
                float b = reader.ReadSingle();
                float c = reader.ReadSingle();
                Vector3 v = new Vector3(a,b,c);
                ((Godot.Collections.Array)dataPackage["points3D"])[_i]=v;
            }

            

            
            Godot.Collections.Dictionary features=(Godot.Collections.Dictionary)dataPackage["features"];


            features["3DPoints"]=(Godot.Collections.Array<Vector3>)dataPackage["points3D"];
            features["2DPoints"]=(Godot.Collections.Array<Vector2>)dataPackage["points"];


            features["EyeLeft"] =reader.ReadSingle();
            features["EyeRight"] =reader.ReadSingle();
            features["EyeBrowSteepnessLeft"] =reader.ReadSingle();
            features["EyeBrowUpDownLeft"] =reader.ReadSingle();
            
            features["EyeBrowQuirkLeft"] =reader.ReadSingle();
            
            features["EyeBrowSteepnessRight"] =reader.ReadSingle();
            
            features["EyeBrowUpDownRight"] =reader.ReadSingle();
            
            features["EyeBrowQuirkRight"] =reader.ReadSingle();
            
            features["MouthCornerUpDownLeft"] =reader.ReadSingle();
            
            features["MouthCornerInOutLeft"] =reader.ReadSingle();
            
            features["MouthCornerUpDownRight"] =reader.ReadSingle();
            
            features["MouthCornerInOutRight"] =reader.ReadSingle();
            
            features["MouthOpen"] =reader.ReadSingle();

            features["MouthWide"] =reader.ReadSingle();

            

            EmitSignal("onDataPackage");
        }


    }

}
}

public partial class OSFDataInfo : RefCounted
{
    //signal info_updated(new_info)
    [Signal]
    public delegate void info_updatedEventHandler(Godot.Collections.Dictionary new_info);

    Godot.Collections.Dictionary features=new Godot.Collections.Dictionary();
    Godot.Collections.Dictionary OSF_data;
    private float change_rate=24.0f;

    public Godot.Vector2 camera_resolution=new Godot.Vector2(1f,1f);

    public void BuildDataInfo(){
        BuildFeature("EyeLeft",-1.0);
        BuildFeature("EyeRight",-1.0);
        BuildFeature("Blink",-1.0);
        BuildFeature("EyeBrowSteepnessLeft",-1.0);
        BuildFeature("EyeBrowUpDownLeft",-1.0);
        BuildFeature("EyeBrowQuirkLeft",-1.0);
        BuildFeature("EyeBrowSteepnessRight",-1.0);
        BuildFeature("EyeBrowUpDownRight",-1.0);
        BuildFeature("EyeBrowQuirkRight",-1.0);
        BuildFeature("MouthCornerUpDownLeft",-1.0);
        BuildFeature("MouthCornerInOutLeft",-1.0);
        BuildFeature("MouthCornerUpDownRight",-1.0);
        BuildFeature("MouthCornerInOutRight",-1.0);
        BuildFeature("MouthOpen",-1.0);
        BuildFeature("MouthWide",-1.0);
        BuildFeature("Euler",new Vector3(0,0,0),true,new Godot.Vector3(0,0,0));
        BuildFeature("Translation",new Vector3(0,0,0),true,new Godot.Vector3(0,0,0));
        BuildFeature("Quaternion",new Godot.Quaternion(0,0,0,1),true,new Godot.Quaternion(0,0,0,1).Normalized());
        BuildFeature("rightEyeOpen",-1.0);
        BuildFeature("leftEyeOpen",-1.0);
        BuildFeature("leftEyeGaze",new Godot.Quaternion(0,0,0,1),true,new Godot.Quaternion(0,0,0,1).Normalized());
        BuildFeature("rightEyeGaze",new Godot.Quaternion(0,0,0,1),true,new Godot.Quaternion(0,0,0,1).Normalized());
        BuildFeature("horizontalLooking",0.0);
        BuildFeature("verticalLooking",0.0);
        BuildFeature("3DPoints",new Godot.Collections.Array<Vector3>(),false);
        BuildFeature("2DPoints",new Godot.Collections.Array<Vector2>(),false);
        // BuildFeature("",-1.0);
    }
    private void BuildFeature(string featureName,Variant value,bool calibrate=false,Godot.Variant calibrate_base=new Godot.Variant()){
        Godot.Collections.Dictionary feature_content= new Godot.Collections.Dictionary
        {
            { "interpolation", 0.0 },
            { "target_value", value },
            { "current_value", value }
        };
        if(calibrate){
            feature_content.Add("calibrate",calibrate_base);
        }
        features.Add(featureName,(Godot.Collections.Dictionary)feature_content);
    }

    public void update_info(){
        Godot.Collections.Dictionary OSF_features=((Godot.Collections.Dictionary)OSF_data["features"]);
        foreach(string key in ((Godot.Collections.Dictionary)OSF_data["features"]).Keys){
            Godot.Collections.Dictionary cont=((Godot.Collections.Dictionary)features[key]);

            cont["target_value"]=OSF_features[key];
            if((float)cont["interpolation"]==0.0){
                cont["current_value"]=OSF_features[key];}
        }

        Godot.Collections.Array points3D=(Godot.Collections.Array)OSF_data["points3D"];
        Godot.Collections.Array points2D=(Godot.Collections.Array)OSF_data["points"];

        Godot.Vector3 HeadPosition = ((Godot.Vector3)points3D[0]+(Godot.Vector3)points3D[16])*0.5f-(Godot.Vector3)(((Godot.Collections.Dictionary)features["Translation"])["calibrate"]);
        
        Godot.Collections.Dictionary translation = (Godot.Collections.Dictionary)features["Translation"];

        translation["target_value"]=HeadPosition;
        if((float)translation["interpolation"]==0.0f) translation["current_value"]=HeadPosition;

        ///Quaternion rotation for the head
        Godot.Collections.Dictionary quat =(Godot.Collections.Dictionary)OSF_data["quaternion"];
        Godot.Collections.Dictionary feat = (Godot.Collections.Dictionary)features["Quaternion"];
        Godot.Quaternion OSF_QUATERNION=new Godot.Quaternion((float)quat["x"],(float)quat["y"],(float)quat["z"],(float)quat["w"]);
        
        Godot.Vector3 fixed_head = new Godot.Vector3(((Godot.Vector2)points2D[0]).X+((Godot.Vector2)points2D[16]).X,((Godot.Vector2)points2D[0]).Y+((Godot.Vector2)points2D[16]).Y,0.0f)*0.5f;

    	OSF_QUATERNION=Godot.Quaternion.FromEuler(
    		OSF_QUATERNION.GetEuler()-((Godot.Quaternion)feat["calibrate"]).GetEuler()-new Godot.Vector3((fixed_head.Y/camera_resolution.Y)*3.14156f-1.25664f,(fixed_head.X/camera_resolution.X)*3.14159f-1.25664f,0.0f)
	    );
        feat["target_value"]=OSF_QUATERNION;
	    if((float)feat["interpolation"]==0.0) feat["current_value"]=OSF_QUATERNION;

        //quaternions for the eye gaze directions
        
		Godot.Vector3 rightGaze = -Godot.Basis.LookingAt((Vector3)points3D[66]*new Vector3(-1,1,1) - (Vector3)points3D[68]*new Vector3(-1,1,1)).GetEuler();
		Godot.Vector3 leftGaze = -Godot.Basis.LookingAt((Vector3)points3D[67]*new Vector3(-1,1,1) - (Vector3)points3D[69]*new Vector3(-1,1,1)).GetEuler();
        Godot.Collections.Dictionary leftEye=(Godot.Collections.Dictionary)features["leftEyeGaze"];
        Godot.Collections.Dictionary rightEye=(Godot.Collections.Dictionary)features["rightEyeGaze"];

		Godot.Quaternion rightGazeQ=Quaternion.FromEuler(
				rightGaze-((Quaternion)rightEye["calibrate"]).GetEuler()
		);
		Godot.Quaternion leftGazeQ=Quaternion.FromEuler(
				leftGaze-((Quaternion)leftEye["calibrate"]).GetEuler()
		);
		leftEye["target_value"]=leftGazeQ;
		rightEye["target_value"]=rightGazeQ;
		if ((float)leftEye["interpolation"]==0.0) leftEye["current_value"]=leftGazeQ;
		if ((float)rightEye["interpolation"]==0.0) rightEye["current_value"]=rightGazeQ;
		
		Vector3 gaze_average=(leftGazeQ.GetEuler()+rightGazeQ.GetEuler())*0.5f;
		Vector2 gaze_direction=new Godot.Vector2(gaze_average.Y*0.31831f,gaze_average.X*0.31831f);
		
        
        Godot.Collections.Dictionary HoriLook=(Godot.Collections.Dictionary)features["horizontalLooking"];
        Godot.Collections.Dictionary VertiLook=(Godot.Collections.Dictionary)features["verticalLooking"];
        

		HoriLook["target_value"]=gaze_direction.X;
		VertiLook["target_value"]=gaze_direction.Y;
		if((float)HoriLook["interpolation"]==0.0) HoriLook["current_value"]=gaze_direction.X;
		if((float)VertiLook["interpolation"]==0.0) VertiLook["current_value"]=gaze_direction.Y;

        float EyeLD=(float)OSF_data["leftEyeOpen"];
        float EyeRD=(float)OSF_data["rightEyeOpen"];
        Godot.Collections.Dictionary EyeLF=(Godot.Collections.Dictionary)features["leftEyeOpen"];
        Godot.Collections.Dictionary EyeRF=(Godot.Collections.Dictionary)features["rightEyeOpen"];
        Godot.Collections.Dictionary BlinkF=(Godot.Collections.Dictionary)features["Blink"];

        EyeLF["target_value"]=EyeLD;
        EyeRF["target_value"]=EyeRD;
        if((float)EyeLF["interpolation"]==0.0f) EyeLF["current_value"]=EyeLD;
        if((float)EyeRF["interpolation"]==0.0f) EyeRF["current_value"]=EyeRD;
        bool is_blinking=(EyeLD+EyeRD<0.4f);
        BlinkF["target_value"]=is_blinking?1f:0f;
        if((float)BlinkF["interpolation"]==0.0f) BlinkF["current_value"]=is_blinking?1f:0f;



    }
    
    public void _update_features(float delta){
        delta = 60*delta;
        
        //general purpose stuff here
        foreach(string feature in features.Keys){
            Godot.Collections.Dictionary cont=((Godot.Collections.Dictionary)features[feature]);
		    if (!(cont["current_value"].VariantType==Godot.Variant.Type.Float)) continue;
            if ((float)cont["interpolation"]>0.0f){
                float change_rate=(float)cont["interpolation"];
                cont["current_value"]=Godot.Mathf.Lerp((float)cont["current_value"],(float)cont["target_value"],change_rate*delta);
        }}
        //head rotation
        Godot.Collections.Dictionary feat=(Godot.Collections.Dictionary)features["Quaternion"];
        if((float)feat["interpolation"]>0.0f){
		    var cur_val=((Godot.Quaternion)feat["current_value"]).Normalized();
		    var lerp_speed=feat["interpolation"];
		    feat["current_value"]=((Godot.Quaternion)cur_val).Slerp(((Godot.Quaternion)feat["target_value"]).Normalized(),(float)lerp_speed*delta);
            features["Quaternion"]=feat;
        }
        //needs to update eyes too now
        //they dont get interpolation currently
        feat=(Godot.Collections.Dictionary)features["leftEyeGaze"];
        if((float)feat["interpolation"]>0.0f){
		    var cur_val=((Godot.Quaternion)feat["current_value"]).Normalized();
		    var lerp_speed=feat["interpolation"];
		    feat["current_value"]=((Godot.Quaternion)cur_val).Slerp(((Godot.Quaternion)feat["target_value"]).Normalized(),(float)lerp_speed*delta);
            features["leftEyeGaze"]=feat;
        }
        feat=(Godot.Collections.Dictionary)features["rightEyeGaze"];
        if((float)feat["interpolation"]>0.0f){
		    var cur_val=((Godot.Quaternion)feat["current_value"]).Normalized();
		    var lerp_speed=feat["interpolation"];
		    feat["current_value"]=((Godot.Quaternion)cur_val).Slerp(((Godot.Quaternion)feat["target_value"]).Normalized(),(float)lerp_speed*delta);
            features["rightEyeGaze"]=feat;
        }




        EmitSignal("info_updated",features);
    }

    public void load_storage_dictionary(Godot.Collections.Dictionary input){
        foreach(string value in input.Keys){
            if(!features.ContainsKey(value)) continue;
            if(!((Godot.Collections.Dictionary)features[value]).ContainsKey("calibrate")) continue;
            Godot.Collections.Dictionary feat=(Godot.Collections.Dictionary)features[value];
            Godot.Collections.Dictionary inp=(Godot.Collections.Dictionary)input[value];
            feat["calibrate"]=inp["calibrate"];
            feat["interpolation"]=inp["interpolation"];
        }
    }
    public Godot.Collections.Dictionary get_storage_dictionary(){
        Godot.Collections.Dictionary output=new Godot.Collections.Dictionary();
        foreach(string value in features.Keys){
            output[value]=((Godot.Collections.Dictionary)features[value]).Duplicate();
            ((Godot.Collections.Dictionary)output[value]).Remove("target_value");
            ((Godot.Collections.Dictionary)output[value]).Remove("current_value");
        }
        return output;
    }

    public void calibrateAll(){
        foreach(string feature in features.Keys){
            calibrateFeature(feature);
        }
    }
    public void calibrateFeatures(Godot.Collections.Array list){
        foreach(string value in list){
            calibrateFeature(value);
        }
        
    }

    public void calibrateFeature(string feature){
        Godot.Collections.Dictionary feat=(Godot.Collections.Dictionary)features[feature];
        if(!feat.ContainsKey("calibrate")) return;
        var feature_type=feat["calibrate"].VariantType;
        switch(feature_type){
            case Godot.Variant.Type.Quaternion:
                feat["calibrate"]=Godot.Quaternion.FromEuler(((Godot.Quaternion)feat["target_value"]).GetEuler()+((Godot.Quaternion)feat["calibrate"]).GetEuler());
                break;
            case Godot.Variant.Type.Vector3:
                feat["calibrate"]=((Godot.Vector3)feat["target_value"])+((Godot.Vector3)feat["calibrate"]);
                break;
            case Godot.Variant.Type.Vector2:
                feat["calibrate"]=((Godot.Vector2)feat["target_value"])+((Godot.Vector2)feat["calibrate"]);
                break;
            case Godot.Variant.Type.Float:
                feat["calibrate"]=(Godot.Variant)(((float)feat["target_value"])+((float)feat["calibrate"]));
                break;
            case Godot.Variant.Type.Int:
                feat["calibrate"]=(Godot.Variant)(((int)feat["target_value"])+((int)feat["calibrate"]));
                break;
            default:
                break;

            
        }
        
    }

    public Godot.Vector2 getHeadPosition(){
        Godot.Collections.Array<Vector2> points = (Godot.Collections.Array<Vector2>)((Godot.Collections.Dictionary)features["2DPoints"])["target_value"];
        return (points[0]+points[16])*0.5f;
    }


    public void bindEvent(Callable eventCallable){
        info_updated+=(data)=>eventCallable.Call(data);
    }
    public void ConnectInfoToSignal(OSFHandlerNode.OSFHandler handler){
        handler.onDataPackage += update_info;
        OSF_data=handler.getPackage();
    }

}