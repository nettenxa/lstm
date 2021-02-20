txt='StrickyRice';
.../  180 168 156 144 132 120 109 //+1
.../  49  37  25  13   1

be=24;
te=23;
numTimeStepsTrain=13;
fr=1;

HiddenLayer = 275;
Epochs = 250;
BatchSize = 50000;

round=1;
for n=1:round
    data = readtable('C:\Users\User\Documents\MATLAB\demo\เอาจริง\Final\ราคา\input\CSV\ข้าวเหนียว-1.csv');

    Price = data.Price;
    Price = Price';
  
    dataTrain = Price(fr:numTimeStepsTrain);
    dataTest = Price(numTimeStepsTrain-1:be);
   ... dataTest
    
    input = Price(fr+1:numTimeStepsTrain);
    
    mu = mean(dataTrain);
    sig = std(dataTrain);

    dataTrainStandardized = (dataTrain - mu) / sig;

    XTrain = dataTrainStandardized(1:end-1);
    YTrain = dataTrainStandardized(2:end);
    
   ... XTrain = num2cell(XTrain,1);
   ... YTrain = num2cell(YTrain,1);
    
   ...YTrain
    
    numFeatures = 1;
    numResponses = 1;
    numHiddenUnits = HiddenLayer;

    layers = [ ...
        sequenceInputLayer(numFeatures)
        lstmLayer(numHiddenUnits,'OutputMode','sequence') 
        fullyConnectedLayer(numResponses)
        regressionLayer];

    ... adam  sgdm  rmsprop
    options = trainingOptions('adam', ...
        'MiniBatchSize',BatchSize, ...
        'MaxEpochs',Epochs, ...
        'InitialLearnRate',0.005, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',125, ...
        'LearnRateDropFactor',0.2, ...
        'SequenceLength','longest',...
        'Verbose',true, ...
        'Plots','training-progress', ...
        'ExecutionEnvironment', 'gpu');
    
    net = trainNetwork(XTrain,YTrain,layers,options);
    
    data = readtable('C:\Users\User\Documents\MATLAB\demo\เอาจริง\Final\ราคา\input\CSV\อัตราแลกเปลี่ยน.csv');
    
    Interest = data.Interest;
    Interest = Interest';
    
    XTest = Interest(fr:numTimeStepsTrain);
    YTest = Interest(numTimeStepsTrain-1:be);
    
    dataTestStandardized = (dataTrain - mu) / sig;
    XTest = dataTestStandardized(1:end-1);
    
    net = resetState(net);
    YPred = predict(net,XTest);   
    YPred = sig*YPred + mu;
    
    .../////////////////////////...
   ... net = trainNetwork(XTrain,YTrain,layers,options);
    
    data = readtable('C:\Users\User\Documents\MATLAB\demo\เอาจริง\Final\ราคา\input\CSV\อัตราดอกเบี้ย.csv');
    
    Interest = data.Interest;
    Interest = Interest';
    
    XTest = Interest(fr:numTimeStepsTrain);
    YTest = Interest(numTimeStepsTrain-1:be);

    dataTestStandardized = (dataTrain - mu) / sig;
    XTest = dataTestStandardized(1:end-1);
    
    net = resetState(net);
    YPred = predict(net,XTest);   
    YPred = sig*YPred + mu;
    
    .../////////////////////////...
   ... net = trainNetwork(XTrain,YTrain,layers,options);
    
    data = readtable('C:\Users\User\Documents\MATLAB\demo\เอาจริง\Final\ราคา\input\CSV\เงินหมุนเวียน.csv');
    
    Money = data.Money;
    Money = Money';
    
    XTest = Money(fr:numTimeStepsTrain);
    YTest = Money(numTimeStepsTrain-1:be);

    dataTestStandardized = (dataTrain - mu) / sig;
    XTest = dataTestStandardized(1:end-1);
    
    net = resetState(net);
    YPred = predict(net,XTest);   
    YPred = sig*YPred + mu;

    .../////////////////////////...
    net = predictAndUpdateState(net,XTrain);
    [net,YPred] = predictAndUpdateState(net,YTrain(end));

    numTimeStepsTest = numel(XTest);
    for i = 2:numTimeStepsTest
        [net,YPred(:,i)] = predictAndUpdateState(net,YPred(:,i-1),'ExecutionEnvironment','cpu');
    end
    
    YPred = sig*YPred + mu;
    YTest = dataTest(2:end);
    Pred = YPred(1:12);
    rmse = sqrt(mean((YPred-YTest).^2))
    error = YPred-YTest;
    absolute = abs(error);
    mae = mean(error)
  ...  endS = numTimeStepsTrain-fr
  ...  startS = (endS+1)-12 ... 2y = (endS+1)/2 //3-5y = (endS+1)-12
    
  ...  testPlot = input(startS:endS);
 ...   y1 = ((testPlot(1:end, 1:end)));  %have to transpose as plot plots columns
  ...  one = plot(y1)
  ...  hold on
    
  ...  testPred = YPred(startS:endS);
  ...  y2 = ((testPred(1:end, 1:end))');
  ...  two = plot(y2)
  ...  xlabel("Year-(Month)")
  ...  ylabel("Yield")
  ...  title("Forecast")
  ...  legend(["Observed" "Forecast"])

  ...  graphW = {'G1.jpg','G2.jpg','G3.jpg','G4.jpg','G5.jpg'};
  ...  figW = {'figure_1.fig','figure_2.fig','figure_3.fig','figure_4.fig','figure_5.fig'};
    
  ...  graph = string(graphW(n));
  ...  saveas(one,graph);
    
  ...  figure = string(figW(n));
  ...  saveas(one,figure);
    ...////////////////////
    .../////////////////////////...
        
 ...   fileID = fopen('testest.txt','w');
 ...   fprintf(fileID,'/////////////////////\n');
 ...   fprintf(fileID,'1,%f\n',input);
 ...   fprintf(fileID,'2,%f\n',YPred);
...    dataTest
    .../////////////////////////...
    numTimeStepsTrain = numTimeStepsTrain-1;
    figure
    plot(dataTrain(1:end-1))
    hold on
    idx = numTimeStepsTrain:(numTimeStepsTrain+numTimeStepsTest);
    plot(idx,[Price(numTimeStepsTrain) Pred-1],'.-')
    hold off
    xlabel("Month")
    ylabel("Cases")
    title("Forecast")
    legend(["Observed" "Forecast"])
    
    figure
    subplot(2,1,1)
    plot(YTest)
    hold on
    plot(YPred,'.-')
    hold off
    legend(["Observed" "Forecast"])
    ylabel("Cases")
    title("Forecast")
    subplot(2,1,2)
    stem(YPred - YTest)
    xlabel("Month")
    ylabel("Error")
    title("RMSE = " + rmse + " MAE = " +mae)
 ...  [is] = rmseTest('testest.txt');
 ...   if is==2
 ...       is=1;
 ...   end
 ...   close all
 ...   delete(findall(0));

end
