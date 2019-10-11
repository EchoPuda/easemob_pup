# easemob_plu

环信插件

## Getting Started

接入方法参考环信官网

使用方法：

  pubspec.yaml:

    easemob_plu:
      git:
        url: https://github.com/EchoPuda/easemob_pup.git

  导入：

  import 'package:easemob_plu/easemob_plu.dart' as easemob;

  使用：
  
    ///方法调用
    await easemob.initEaseMobPlu(
      autoInvitation: true,
      debugMode: true,
      autoLogin: true,
      appKey: "",
    );
    
    ///监听回调
    easemob.responseFromDisConnect.listen((data) {
      print(data);
    });
    
  具体请查看easemob_plu.dart中的注释
  
  


