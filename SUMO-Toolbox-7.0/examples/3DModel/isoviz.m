% Cactus
x = 0.4339:0.01:0.57;
y = 0.2468:0.01:0.7532;
z = 0.1:0.01:0.9;

% Skull
x = -5.88:0.5:9.7;
y = -7.45:0.5:10.7;
z = -12.54:0.5:8.87;

% Bunny
x = -0.0947:0.01:0.0610;
y = 0.0330:0.01:0.1873;
z = -0.0619:0.01:0.0588;

% Hand
x = -44:1:43;
y = -100:2:101;
z = -37:1:39;
  
[X Y Z] = meshgrid(x,y,z);

res = model.evaluate([X(:),Y(:),Z(:)]);

res = permute(res, [2 1 3]); 

mat = reshape(res,length(y),length(x),length(z));

volume_browser(mat);
