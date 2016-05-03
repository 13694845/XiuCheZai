//
//  ScannerViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/5/3.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ScannerViewController.h"

@import AVFoundation;

@interface ScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureSession *session;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    [self.session addInput:input];
    [self.session addOutput:output];
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(60.0, 100.0, 200.0, 200.0)];
    boxView.layer.borderColor = [UIColor greenColor].CGColor;
    boxView.layer.borderWidth = 1.0;
    [self.view addSubview:boxView];
    output.rectOfInterest = CGRectMake(boxView.frame.origin.y / self.view.bounds.size.height,
                                       boxView.frame.origin.x / self.view.bounds.size.width,
                                       boxView.bounds.size.height / self.view.bounds.size.height,
                                       boxView.bounds.size.width / self.view.bounds.size.width);
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    [self.session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        NSLog(@"%@", metadataObject.stringValue);
        [self.session stopRunning];
        
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
