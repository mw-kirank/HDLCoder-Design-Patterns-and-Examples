function mlhdlc_vht_sobel_viewer(actPixPerLine,actLine,I)
    persistent viewer    
    if isempty(viewer)
        viewer = vision.DeployableVideoPlayer(...    
            'Size','Custom',...
            'CustomSize',[2*actPixPerLine actLine]/4);
    end
    
    step(viewer,I);    