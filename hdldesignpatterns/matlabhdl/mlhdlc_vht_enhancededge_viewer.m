function mlhdlc_vht_enhancededge_viewer(actPixPerLine,actLine,I,J)
    persistent viewer1 
    persistent viewer2
    if isempty(viewer1)
        viewer1 = vision.DeployableVideoPlayer(...
            'Location',[100 200],...
            'Size','Custom',...
            'CustomSize',[4*actPixPerLine actLine]*.75); 
        viewer2 = vision.DeployableVideoPlayer(...
            'Location',[100 226+actLine*.75],...
            'Size','Custom',...
            'CustomSize',[2*actPixPerLine actLine]*.75);  
    end
    
    step(viewer1,I);
    step(viewer2,J);  