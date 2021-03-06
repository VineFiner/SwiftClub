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


## vapor

Vapor3


## docker 部署

隔离本地环境，建议采用 docker,  项目已写好相关脚本。
部署:

1. 安装 [docker](https://www.docker.com/products/docker-desktop) ， 并且运行
2. 第一次部署项目，切到该工程根目录执行

    ```sh
    docker-compose up    
    ```

3. 当你代码改动的时候，需要进行重新编译

    ```sh
    # 重新编译
    docker-compose build
    # 然后
    docker-compose up
    ```

    

## 网站网址： 

https://swiftclub.loveli.site

## 项目博文

[项目系列博文](https://xiaozhuanlan.com/topic/7869023451)

## 微信订阅号

请搜索 SwiftClub


