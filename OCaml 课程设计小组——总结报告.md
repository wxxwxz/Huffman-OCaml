#  OCaml 课程设计小组——总结报告

- 课设选题：基于Huffman树数据结构的编码和解码

---

## 目录

[TOC]

## 内容

 ### 1.实现功能介绍

本次课程设计的内容为小组合作。用OCaml语言构造Huffman树数据结构，实现对文本的编码和解码。

编码：从1号文件中读取原文，构建Huffman树，对原文进行Huffman编码，并将Huffman树和编码结果输出到2号文件

解码：通过编码生成的2号密文文件，然后构建Huffman树，并根据密文的二进制数进行解码，输出到3号文件；

**小组分工**

哈夫曼编码

哈夫曼解码



### 2.项目文件构成

`io.mli`和`io.mli`两个文件中包含了文件读写操作，包括字符串、字符、二进制相关操作；

`heap.mli`和`heap.ml`两个文件，这两个文件主要用于编码时构建Huffman树，针对每个字符出现的次数进行堆排序。

`io`和`heap`中的大部分代码出自 《More OCaml》这本书，我们对这些代码进行了调试和少量修改；

```
+-----+ io.mli    +----------+ io.ml   +-----+
|                                            |	   
+-----+ heap.mli  +----------+ heap.ml +-----+
|                                            |
+----------- encode.ml <<--------------------+
|                                            |
+----------- decode.ml <<--------------------+

```

### 3.具体设计内容

**(1)编码**

详见文件夹内*的个人实验报告；

**(2)解码**

详见文件夹内*的个人实验报告；

### 4.运行结果展示

执行以下指令编译运行

```
$ ocamlc heap.mli heap.ml io.mli io.ml encode.ml -o encode
$ ./encode 1.txt 2.txt

$ ocamlc heap.mli heap.ml io.mli io.ml decode.ml -o decode
$ ./decode 2.txt 3.txt
```

编码编译运行：

![编码运行打码](D:\文件\课程\大三\ocaml\pic\编码运行打码.jpg)

原文：

![1txt](D:\文件\课程\大三\ocaml\pic\1txt.png)

编码结果文件：

![2txt](D:\文件\课程\大三\ocaml\pic\2txt.png)

解码编译运行：

![解码编译打码](D:\文件\课程\大三\ocaml\pic\解码编译打码.jpg)!

解码后文件：

![3txt](D:\文件\课程\大三\ocaml\pic\3txt.png)



### 5.总结

​	有关选题，最初，我们打算是实现区块链相关的算法，迫于时间的压力，查阅资料的过程中，我们突然想起之前做过的Huffman编码、解码。规模适中，分工明确，于是我们选择了Huffman。老师曾说过，OCaml是一门非常适合区块链开发的语言，这次没能亲手实践体会一下，算是一点小遗憾吧。

​	在本次的课程设计中，我们小组充分意识到了交流合作的重要性。之前的很多课程设计，都是个人完成，相比合作完成就非常的自由。本次的课设中，我们讨论并协调统一了Huffman数的数据结构、中间生成的2号文件的文件格式，所以，两个人基本是同时开始的，合理利用了时间。毕竟，编码、解码都由个人完成还是非常紧张的。这让我们间接认识到了“接口”的重要性。

​	本次的课设，让我们意识到了OCaml的精髓——“模式匹配”、“递归”等，OCaml的模式匹配功能很强大，是这门语言很大的亮点。在学习的过程中，我们也明白了再学习一门新语言时要学会去查阅这门语言的官方文档，有很多库函数的具体用法在官方文档里都记载的非常详细。

​	最后，我们祝老师科研顺利！万事顺遂！



### 6.参考文献

[1]陈刚,张静.OCaml语言编程基础教程[M].人民邮电出版社:北京,2018.

[2]Minsky,Madhavapeddy,Hickey.Real World OCaml[M].中国电力出版社:北京,2015.

[3]严蔚敏,吴伟民.数据结构[M].清华大学出版社:北京,2007.

[4]Xavier Leroy, Damien Doligez, Alain Frisch, Jacques Garrigue, Didier R´emy and J´erˆome Vouillon.The OCaml system release 4.09[EB/OL].http://caml.inria.fr/distrib/ocaml-4.09/ocaml-4.09-refman.pdf,2019-9-11.

[5] John Whitington ,More OCaml: Algorithms, Methods, and Diversions[M] Coherent Press (June 7, 2013).

