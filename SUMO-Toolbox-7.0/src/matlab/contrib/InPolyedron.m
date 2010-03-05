function in=InPolyedron(p,t,tnorm,qp)
% InPolyedron detects points inside a manifold closed surface. The normal
% orientation is assumed to be outward. Warning there is no check for
% closed surface or normal orientation. The v3 version, differently from v1
% and v2 supports points lying on edges or point. In the limit of numerical
% accuracy, points lying on the surface will be considered in.
% 
% 
% Input:
% 
% p: POints of the surface npx3 array
% 
% t:triangles indexes, first points flagged as one, ntx3 array
% 
% tnorm: outward normals of traingles, ntx3 array
% 
% qp: points to be queried, nqx3 array
% 
% 
% Output:
% 
% in: nqx1 logical vector, true for in, false for out
% 
% 
% Author: Giaccari Luigi 
% Created: 15/05/2009
% e-mail: giaccariluigi@msn.com
% 
% Visti my website: http://giaccariluigi.altervista.org/blog/
% 
% This work is free thanks to users gratitude. If you find it usefull
% consider making a donation on my website.




%possibili migliorie:
% - Effettuare il test con il numero di intersioni pari o dispari per la
% maggiorparte dei punti e passare all'attuale test per i casi dubbi.


%errors check
if nargin~=4
    error('4 inputs required')
end

[m,n]=size(p);
if n~=3
    error('Wrong points dimension');
end

[m1,n]=size(t);
if n~=3
    error('Wrong t dimension');
end

[m2,n]=size(tnorm);
if n~=3
    error('Wrong tnorm dimension');
end

if m1~=m2
    error('t dismatch tnorm dimensions');
end

[m,n]=size(qp);
if n~=3
    error('Wrong qp dimension');
end

%% internal parameters


k=1;%boxes subdivison factor
%future improvement find anoptimal value depending on t and qp size



%rectangle for box2triangle map
rect(1)=min(p(:,1));
rect(2)=min(p(:,2));

rect(3)=max(p(:,1));
rect(4)=max(p(:,2));


global firsttoll;
global secondtoll;

firsttoll=1e-9;
secondtoll=1e-10;



%get size data

np=size(p,1);
% nt=size(t,1);
nq=size(qp,1);


%Sort counterclockwise
t=SortCounterclockwise(t,p(:,1),p(:,2));


% Box2tMap
[Box2tMap]=GetBox2tMap(p,t,tnorm,rect,k);

in=false(nq,1);

%get box reference
minx=rect(1);%min(p(:,1));
miny=rect(2);%min(p(:,2));

maxx=rect(3);%max(p(:,1));
maxy=rect(4);%max(p(:,2));

A=(maxx-minx)*(maxy-miny);
step=sqrt(A/(np*k));%step quasi square
nx=floor((maxx-minx)/step);
ny=floor((maxy-miny)/step);

if nx==0%check thin mapping
    px=firsttoll+maxx-minx;
    nx=1;
else
px=(maxx-minx+firsttoll)/nx;%eps per aumentare il passo
end
if ny==0%check thin mapping
    py=firsttoll+(maxy-miny);
    ny=1;
else
    py=(maxy-miny+firsttoll)/ny;
end


%loop trough all query points

n=zeros(2,1);%edge normal
for i=1:nq
    
    %make temp scalar
    x=qp(i,1); y=qp(i,2); z=qp(i,3);
    
    %get box coordinates
    idx=ceil((x-rect(1)+secondtoll)/px);
    if idx<1||idx>nx
        continue%points is outside
    end
    idy=ceil((y-rect(2)+secondtoll)/py);
    if idy<1||idy>ny
        continue%points is outside
    end
    
    id=ny*(idx-1)+idy;
    
    %get mapped triagnles
    
   ttemp=Box2tMap{id,1};

   %loop trough all triangles
   mindist=inf;N=1;
   for j=1:length(ttemp)
       idt=ttemp(j);
       p1=t(idt,1);p2=t(idt,2);p3=t(idt,3);
    
       %run inside triangle test
       
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % edge1
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       n(1)=-p(p2,2)+p(p1,2);n(2)=p(p2,1)-p(p1,1);%normals to triangle edge
       test=n(1)*x+n(2)*y-n(1)*p(p1,1)-n(2)*p(p1,2);
       
       %debug
%        close(figure(1));
%        figure(1)
%        hold on
%        plot(p([p2,p1],1),p([p2,p1],2),'r-')
%        plot(qp(i,1),qp(i,2),'g*')
%        
       if test<0%mettendo l'uguale si escludono i punti sulla superficie
           continue;%test failed pints is outside of the triangle

       end
       
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % edge2
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       n(1)=-p(p3,2)+p(p2,2);n(2)=p(p3,1)-p(p2,1);%normals to triangle edge
       test=n(1)*x+n(2)*y-n(1)*p(p2,1)-n(2)*p(p2,2);
       
       %debug
%        figure(1)
%        hold on
%        plot(p([p3,p2],1),p([p3,p2],2),'r-')
%      
       
       if test<0%mettendo l'uguale si escludono i punti sulla superficie
           continue;%test failed pints is outside of the triangle

       end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % edge3
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       
        n(1)=-p(p1,2)+p(p3,2);n(2)=p(p1,1)-p(p3,1);%normals to triangle edge
       test=n(1)*x+n(2)*y-n(1)*p(p1,1)-n(2)*p(p1,2);
       
       %debug
%        figure(1)
%        hold on
%        plot(p([p1,p3],1),p([p1,p3],2),'r-')
%      
       
       if test<0%mettendo l'uguale si escludono i punti sulla superficie
           continue;%test failed pints is outside of the triangle
       end
   
       
       %debug
%        close(figure(2));
%        figure(2);
%        hold on
%        axis equal
%        trisurf(t(idt,:),p(:,1),p(:,2),p(:,3),'facecolor','c');
%        cc=(p(t(idt,1),:)+p(t(idt,2),:)+p(t(idt,3),:))/3;
%        quiver3(cc(1),cc(2),cc(3),tnorm(idt,1),tnorm(idt,2),tnorm(idt,3))
%        plot3(x,y,z,'g*');
%        
%    end
   
   
   
   %run semispace test with closest triangle

       n1=tnorm(idt,1);n2=tnorm(idt,2);n3=tnorm(idt,3);
       p1=t(idt,1);
       d=-n1*p(p1,1)-n2*p(p1,2)-n3*p(p1,3);
       
       %run distance test triangle test
       
       dist=z-(-n1*x-n2*y-d)/n3;%distance along ray
       if abs(dist)<abs(mindist)
           mindist=dist;
           N=n3;
       end
   end
   
   

       in(i)=mindist*N<=0;


end


end


%% Build2DBoxes
function [Box2tMap]=GetBox2tMap(p,t,tnorm,rect,k)


%rect contiene gli estrameli del rettagnolo di divisione.
%k è il fattore di divisione delle boxes, per k=1 il numero di scatole sarà
%uguale al numero di punti. k=2 qudruplicherà il numero delle scatole


global firsttoll;
global secondtoll;


%size parameters
np=size(p,1);
nt=size(t,1);



%bounding box analysis
minx=rect(1);%min(p(:,1));
miny=rect(2);%min(p(:,2));

maxx=rect(3);%max(p(:,1));
maxy=rect(4);%max(p(:,2));

A=(maxx-minx)*(maxy-miny);
step=sqrt(A/(np*k));%step quasi square

nx=floor((maxx-minx)/step);%nota: non cambiare floor con ceil
ny=floor((maxy-miny)/step);


if nx==0%check thin mapping
    px=firsttoll+maxx-minx;
    nx=1;
else
px=(maxx-minx+firsttoll)/nx;%eps per aumentare il passo
end
if ny==0%check thin mapping
    py=firsttoll+(maxy-miny);
    ny=1;
else
    py=(maxy-miny+firsttoll)/ny;
end


%nota 1e-9 per aumentare il passo in modo da evitare nel passo successivo u
%indice più grande del numero delle scatole


N=nx*ny;%real Boxes number

Box2tMap=cell(N,1);
BoxesId=zeros(np,2,'int32');




%first loop to count points and get ceiling round
for i=1:np
    idx=ceil((p(i,1)-minx+secondtoll)/px);
    idy=ceil((p(i,2)-miny+secondtoll)/py);
%     id=ny*(idx-1)+idy;
     BoxesId(i,1)=idx;
     BoxesId(i,2)=idy;
end

c=zeros(N,1,'int32');

%now loop trough all triangles a build the map

for i=1:nt
     
    if abs(tnorm(i,3))<0.00000000001%jump vertical triangles
        continue
    end
    
    p1=t(i,1); p2=t(i,2); p3=t(i,3);
    
    %get extreme values 
    idxmax=max(BoxesId([p1,p2,p3],1));
    idxmin=min(BoxesId([p1,p2,p3],1));
    idymax=max(BoxesId([p1,p2,p3],2));
    idymin=min(BoxesId([p1,p2,p3],2));
    
    %loop trough all boxes that may contains the triangle
    for idx=idxmin:idxmax
        for idy=idymin:idymax
           
            %get boxes id and increase counter
            id=ny*(idx-1)+idy; 
            c(id)=c(id)+1;
            Box2tMap{id,1}(c(id))=i;%insert traingle into map
            
        end
    end
    
    
end

end



%% SortCounterclockwise
function t=SortCounterclockwise(t,x,y)

%get points coordinate vectors
x1=x(t(:,1));x2=x(t(:,2));x3=x(t(:,3));
y1=y(t(:,1));y2=y(t(:,2));y3=y(t(:,3));


cx=(x1+x2+x3)/3;cy=(y1+y2+y3)/3;%centroid
clear x3 y3

v1x=x1-cx;v1y=y1-cy;

v2x=x2-cx;v2y=y2-cy;


cp=(v1x.*v2y-v1y.*v2x)<0;%fails cross product criterion

t(cp,:)=t(cp,[2 1 3]);%get counterclockwise orientation

end




