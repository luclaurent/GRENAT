function [fct,dfct,infos,ddfct]=funManu(x,~)
v=2;


%prepare for demo mode
dem=false;
if nargin==0
    x=linspace(-5,15,300);
    dem=true;
end

if v==1
    fct=15*cos(x)+20;
    if nargout>=2||dem
        dfct=-15*sin(x);
    end
    %information about the function
    if nargout>=3
        %on [-1,15]
        pts=[1;3]*pi;
        infos.min_loc.X=pts;
        infos.min_loc.Z=15*cos(pts)+20;
        infos.min_glob.X=infos.min_loc.X;
        infos.min_glob.Z=infos.min_loc.Z;
    end
elseif v==2
    a=10;
    b=0;
    fct=exp(-x/a).*cos(x)+1/a*x+b;
    if nargout>=2||dem
        dfct=-exp(-x/a).*(sin(x)+1/a.*cos(x))+1/a;
    end
    if nargout==4
        ddfct=exp(-x/a).*(-cos(x)+2.*sin(x)./a+1/a^2.*cos(x));
    end
    %information about the function
    if nargout>=3
        %on [-1,15]
        infos.min_glob.Z=-0.436559;
        infos.min_glob.X=2.9844;
        infos.min_loc.Z=[-0.436559;0.528402];
        infos.min_loc.X=[2.9844;9.07593];
    end
elseif v==3
    fct=cos(4*x);
    if nargout>=2||dem
        dfct=-4*sin(4*x);
    end
    %information about the function
    if nargout>=3
        %on [-1,15]
        pts=[1;3;5;7;9;11;13;15;17;19]*pi/4;
        infos.min_glob.Z=cos(4*pts);
        infos.min_glob.X=pts;
        infos.min_loc.Z=infos.min_glob.Z;
        infos.min_loc.X=pts;
    end
elseif v==4
    fct=x.^2;
    if nargout>=2||dem
        dfct=2*x;
    end
    %information about the function
    if nargout>=3
        %on [-1,15]
        %pts=[1;3;5;7;9;11;13;15;17;19]*pi/4;
        %infos.min_glob.Z=cos(4*pts);
        % infos.min_glob.X=pts;
        %infos.min_loc.Z=infos.min_glob.Z;
        infos.min_loc.X=[];%pts;
    end
    
elseif v==5
    a=10;
    b=0;
    c=5;
    
    fct=exp(-x/a).*cos(c*x)+1/a*x+b;
    
    if nargout>=2||dem
        dfct=-exp(-x/a).*(sin(x)+1/a.*cos(x))+1/a;
    end
    %information about the function
    if nargout>=3
        %on [-1,15]
        %pts=[1;3;5;7;9;11;13;15;17;19]*pi/4;
        %infos.min_glob.Z=cos(4*pts);
        % infos.min_glob.X=pts;
        %infos.min_loc.Z=infos.min_glob.Z;
        infos.min_loc.X=[];%pts;
    end
end
%demo
if dem
    figure
    subplot(1,2,1)
    plot(x,fct)
    title('Manu');
    subplot(1,2,2)
    plot(x,dfct)
    title('D Manu');
end

end
