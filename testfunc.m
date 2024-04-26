function test = testfunc(E, name)
    %initialise materials class - only once: 
    persistent materials_class    
    if isempty(materials_class)
        materials_class = Materials;
        disp('Class initialised')
    else
        disp('Class already exists')
    end
    test = materials_class.extrapolate_value(E, name);
end
