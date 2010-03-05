function s=factorial_design(nb_data_x, nb_data_y, borne_inf_x, borne_sup_x, borne_inf_y, borne_sup_y)

%---SELECTION NOMBRE NIVEAUX X et Y---

%x_mesure=zeros(1, nb_data_x * nb_data_y);
%y_mesure=zeros(1, nb_data_x * nb_data_y);
xy_array=zeros(nb_data_x * nb_data_y,2);
delta_x=(borne_sup_x - borne_inf_x)/(nb_data_x - 1);
delta_y=(borne_sup_y - borne_inf_y)/(nb_data_y - 1);

for i=1:nb_data_x
    for j=1:nb_data_y
        index=(i-1)*nb_data_y+j;
        xy_array(index,1)=borne_inf_x+(delta_x*(i-1));
        xy_array(index,2)=borne_inf_y+(delta_y*(j-1));
    end
end
s=xy_array;