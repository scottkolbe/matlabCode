behavVect = AS_1stSacPosErr;

lowModularity = groupComodularity(matZ_3D(:,:,find(behavVect > median(behavVect))), 1000, 1);
highModularity = groupComodularity(matZ_3D(:,:,find(behavVect < median(behavVect))), 1000, 2);
