open Io;;
open Heap;;
open Printf;; 

(*Huffman树数据结构*)
type 'a tree = Leaf | Branch of 'a * 'a tree * 'a tree;;

let tree_val tree = 
match tree with
Branch (a, _, _) -> a
| Leaf -> []
;;

(*堆栈操作*)
exception EmptyStack;;
(*压栈，将x加入到s中*)
let push x s = x :: s;;
(*出栈，获得s的top元素*)
let pop s =
  match s with
    | x :: s' -> x
    | [] -> raise EmptyStack;;
(*获得s删除开头元素后的表*)
let tail s =
  match s with
  |x::s' -> s'
  | [] -> raise EmptyStack;;
;;
(*获得s删除开头两个元素的表*)
let tail2 s =
  match s with
  |x::a::s' -> s'
  | _ -> raise EmptyStack;;
;;

(*获取原文*)
let huffman_encode in_channel arr =
  let rec huffman_encode_inner in_channel1 =
    (*逐个扫描符号*)
    let newchar = input_char in_channel1 in
    let pos = int_of_char newchar in
	(*把所有的内容以ascii码存放到数组里面去*)
      arr.(pos) <- arr.(pos) + 1; 
      huffman_encode_inner in_channel1
  in
    try huffman_encode_inner in_channel with 
        End_of_file -> ();;

(*由数组建造Huffman树 *)
let make_tree oldarr newarr =
let placer = ref 0 in
for x = 0 to 255 do 
if oldarr.(x) > 0 then
begin
let newchar = char_of_int x in
newarr.(!placer) <- (Branch([newchar], Leaf, Leaf), oldarr.(x));
placer := !placer + 1
end
done

;;
(*辅助函数*)
(*比较函数，heap.ml会用到*)
let comp x y =
let (_, a) = x in
let (_, b) = y in
if a < b then true else false
;;

(*huffman树*)
let get_tree arr =
(*count统计出现过多少个字符*)
let count = Array.fold_left (fun x y -> if y > 0 then (x + 1) else x) 0 arr in
let newarr = Array.make count (Leaf, 0) in 
(*新数组的结构为元组(tree结构，字符)，元素个数为count*)
make_tree arr newarr;
heap_of_array count comp newarr
;;

(*把堆里面最小的两个子树合并到同一个子树的两个分支*)
let combine_2min_impl heap =
let (char1, a) = remove_min heap in
let (char2, b) = remove_min heap in 
let val1 = tree_val char1 in
let val2 = tree_val char2 in
insert heap (Branch(val1 @ val2, char1, char2), a+b);; (*再把合并的子树加回堆里*)

let combine_2min heap =
try combine_2min_impl heap with 
Empty -> ()
;;

let rec combine_2 heap count = (*递归*)
if count == 0 then () else 
begin 
combine_2min heap;
combine_2 heap (count -1) 
end 
;;

(*递归遍历Huffman树，把记录下来的编码连同字符一起记录到list里面去 *)
let rec encodinghelper tree encoding acc=
match tree with
|Branch ([a], Leaf, Leaf ) -> acc := (a, (List.rev encoding))::!acc
|Branch (_, l, r) -> encodinghelper l (0:: encoding) acc; encodinghelper r (1::encoding) acc (*向左走0，向右走1*)
|_ -> ()
;;

(*list转换成array，后面找编码比较方便*)
let rec placer encoding newarr =
match encoding with
|(a,b)::t -> let wow = int_of_char a in newarr.(wow) <- b; placer t newarr
|[] -> ()
;;

(* list里记录的编码从int 转换成 string，ascii形式*)
let int_2_string l =
let l = List.map (fun x -> x + 48) l in 
let res = Bytes.create (List.length l) in
let rec imp i = function
| [] -> res
| c :: l -> Bytes.set res i  (char_of_int c); imp (i + 1) l in
imp 0 l;;

(*多个char 转换成 string*)
let char_2_string l =
let res = Bytes.create (List.length l) in
let rec imp i = function
| [] -> res
| c :: l -> Bytes.set res i  c; imp (i + 1) l in
imp 0 l;;


let rec converter encoder newlist =
match encoder with
|(a,b)::t -> converter t ((newlist := (a, int_2_string b)::!newlist);newlist)
|[] -> ()
;;


let get_encoding tree newarr =
let encoding_list = ref [] in 
encodinghelper tree [] encoding_list;  
placer !encoding_list newarr
;;


(*输出保存Huffman树*)
let rec save_tree_helper (tr: 'char tree)  ch =
match tr with
|Branch ([k], Leaf, Leaf) -> output_string ch (string_of_int(int_of_char k)); output_char ch '|'
|Branch (k, l, r)-> 
output_string ch "/";
save_tree_helper l ch;
save_tree_helper r ch;
|Leaf ->  output_string ch "L"
;;
(* write down braches as /, each important node write down the int_if_char followed by |*)


let save_tree oc (tr: 'a tree) =
save_tree_helper tr oc;
output_char oc '\n'; (*输完树，换行*)
;;

(*按位写入单个字符编码*)
let rec typewritter output_bits ls =
match ls with 
[] -> ()
|h::t -> if h == 0 then 
begin putbit output_bits false;typewritter output_bits t end 
else (putbit output_bits true;typewritter output_bits t)
;;

let save_encoding ic oc arr =
let newout = output_of_channel oc in
let newout1 = output_bits_of_output newout in 
let rec write1_inner ic1 =
(*逐个字符写入*)
let newchar = input_char ic1 in
let pos = int_of_char newchar in (*找到字符在编码数组对应的位置*)
let code = arr.(pos) in
typewritter newout1 code; (*写入单个字符的编码*)
write1_inner ic1
in
try write1_inner ic with (*直到文件结束*)
End_of_file -> flush newout1;;
;;


let write_result ic oc arr tree =
(*先写树*)
save_tree oc tree;
(*再写编码*)
save_encoding ic oc arr
;;

let encode infile outfile = 
let ch1 = open_in infile in
let newarr = Array.make 256 0 in
(*获取字符出现次数*)
huffman_encode ch1 newarr;
close_in ch1;
(*coder生成堆*)
let coder = get_tree newarr in
let get_size = coder.size in
(*合并最小分支，建Huffman树*)
combine_2 coder (!get_size);
let (huffman_tree,checker) = coder.arr.(0) in
(* 获取编码，放到数组里面去*)
let encodedarr = Array.make 256 [] in 
get_encoding huffman_tree encodedarr; 
(*获取文件名*)
let ch2 = open_out outfile in
let ch3 = open_in infile in
(*输出结果*)
write_result ch3 ch2 encodedarr huffman_tree;
close_out ch2;
close_in ch3
;;
encode (Sys.argv).(1) (Sys.argv).(2);;

(*
编译
ocamlc heap.mli heap.ml io.mli io.ml  encode.ml -o encode
运行
./encode test1.txt test2.txt
*)
