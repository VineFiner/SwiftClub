<p align="center">
    <img src="https://user-images.githubusercontent.com/1342803/36623515-7293b4ec-18d3-11e8-85ab-4e2f8fb38fbd.png" width="320" alt="API Template">
    <br>
    <br>
    <a href="http://docs.vapor.codes/3.0/">
        <img src="http://img.shields.io/badge/read_the-docs-2196f3.svg" alt="Documentation">
    </a>
    <a href="https://discord.gg/vapor">
        <img src="https://img.shields.io/discord/431917998102675485.svg" alt="Team Chat">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://circleci.com/gh/vapor/api-template">
        <img src="https://circleci.com/gh/vapor/api-template.svg?style=shield" alt="Continuous Integration">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-4.1-brightgreen.svg" alt="Swift 4.1">
    </a>
</p>


## TODO:

[ ] 用户系统

    [ ] 注册、登录

    [ ] 邮件激活

    [ ] 邮箱找回密码

    [ ] 修改个人信息

    [ ] 上传头像（七牛云）

    [ ] 每日签到

    [ ] 个人提醒

[ ] 论坛

    [ ] 扁平化的内容展示

    [ ] 创建和管理板块

    [ ] 板块主题颜色

    [ ] 发表和编辑主题

    [ ] @功能

[ ] 管理后台

    [ ] 提供对板块、主题、用户、评论的管理

    [ ] 管理日志

[ ] 安全机制

    [ ] 前端密码加密，后端不取得用户的初始密码，最大限度降低了中间人攻击和数据库泄露的危害

    [ ] 后端再次加密，sha512加盐迭代十万次后储存密码

    [ ] 密码相关API均有防爆破，可设置IP请求间隔和账号请求间隔，分别提升批量撞库和单点爆破的难度

    [ ] 隐私数据，例如IP地址脱敏后才可存入数据库

[ ] 其他

    [ ] 实时在线人数