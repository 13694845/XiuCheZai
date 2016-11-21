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
@property (strong, nonatomic) UIButton *backButton;

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
    // output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    output.metadataObjectTypes = output.availableMetadataObjectTypes;
    
    CGFloat const kBoxWidth = 200.0;
    CGFloat const kBoxHeight = 200.0;
    // UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - kBoxWidth) / 2.0, 120.0, kBoxWidth, kBoxHeight)];
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - kBoxWidth) / 2.0, 120.0, kBoxWidth, kBoxHeight)];
    boxView.layer.borderColor = [UIColor greenColor].CGColor;
    boxView.layer.borderWidth = 1.0;
    [self.view addSubview:boxView];
    
    UIView  *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, (self.view.bounds.size.width - kBoxWidth) / 2.0, self.view.bounds.size.height)];
    leftView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
    [self.view addSubview:leftView];
    UIView  *rightView = [[UIView alloc] initWithFrame:CGRectMake(leftView.bounds.size.width + kBoxWidth, 0.0, (self.view.bounds.size.width - kBoxWidth) / 2.0, self.view.bounds.size.height)];
    rightView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
    [self.view addSubview:rightView];
    UIView  *topView = [[UIView alloc] initWithFrame:CGRectMake(leftView.bounds.size.width, 0.0, kBoxWidth, 120.0)];
    topView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
    [self.view addSubview:topView];
    UIView  *bottomView = [[UIView alloc] initWithFrame:CGRectMake(leftView.bounds.size.width, 120.0 + kBoxHeight, kBoxWidth, self.view.bounds.size.height - 120.0 - kBoxHeight)];
    bottomView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
    [self.view addSubview:bottomView];
    
    [self addBackButton];
    
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

- (void)addBackButton {
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(15.0, 40.0, 25.0, 25.0)];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"common_back.png"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(tapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
}

- (void)tapBackButton:(id)sender {
    [self.backButton removeFromSuperview];
    self.backButton = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [self.session stopRunning];
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    [self.delegate scannerViewController:self didFinishScanningCodeWithInfo:@{@"url":metadataObject.stringValue}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
