%ViewTBImgFile - Views the image from the testbench in matlab
%
% USAGE: In the command window (do not run ViewTBImgFile.m file in MATLAB!) you can run it as
% ViewTBImgFile(FileName). For example we can run the following in the command window
%   ViewTBImgFile("../work_lab08_mandelbrot/work_lab08_mandelbrot.sim/sim_1/behav/xsim/ImgDataFile")
%
% INPUT PARAMETERS:
%   FileName - Name of input file, e.g. "../work_lab08_mandelbrot/work_lab08_mandelbrot.sim/sim_1/behav/xsim/ImgDataFile"

function ViewTBImgFile(FileName)

  ImgWidth  = 1024;
  ImgHeight = 768;

  TBImgFile = fopen(FileName);

  [img, count] = fread(TBImgFile, 'int');

  img = reshape(img, ImgWidth, ImgHeight);
  img = transpose(img);

  image(img);


end
