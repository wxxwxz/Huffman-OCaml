open Io;;
open Heap;;
open Printf;; 


type 'a tree = Leaf | Branch of 'a * 'a tree * 'a tree;;

let valtree tree = 
match tree with
Branch (a, _, _) -> a
| Leaf -> []
;;

exception NullStack;;
exception WuxiaoFile;;
let push x s = x :: s;;
let pop s =
match s with
| x :: s' -> x
| [] -> raise NullStack;;
let endafter1 s =(*取列表除了首个元素的尾巴部分*)
match s with
|x::s' -> s'
| [] -> raise NullStack;
;;

let endafter2 s =(*取列表除了第1个和第2个元素的尾巴部分*)
match s with
|x::a::s' -> s'
| _ -> raise NullStack
;;


let midhelper2 l =(*辅助函数*)
let res = Bytes.create (List.length l) in
let rec imp i = function
| [] -> res
| c :: l -> Bytes.set res i  c; imp (i + 1) l in
imp 0 l;;




let midhelper1 s =
let rec exp i l =
if i < 0 then l else exp (i - 1) (s.[i] :: l) in
exp (String.length s - 1) [];;



let rec treeprocess ls stackof_tree =
match ls with 
|[] -> pop stackof_tree
|h::t -> match h with 
| "/" -> let l = pop stackof_tree in 
let r = pop (endafter1 stackof_tree) in
let operation = Branch ('\\', l, r) in 
treeprocess t (push operation (endafter2 stackof_tree)) 
| a -> let newbranch = Branch ((char_of_int (int_of_string a)), Leaf, Leaf) in treeprocess t (push newbranch stackof_tree) 
;;(*叶子结点*)



let rec tree_preat ls store acc=
match ls with
|[] -> acc 
|'/'::t -> tree_preat t store ("/"::acc)
|'|'::t -> tree_preat t [] (Bytes.to_string (midhelper2 (List.rev store))::acc)  (*List.rev 列表逆转*)
|a::t ->  tree_preat t (a::store) acc

;;


let tree_lister ic = 
let s = input_line ic in
midhelper1 s
;;

let loadtree ic =
let ls = tree_lister ic in  (*例如，114存储的时候是一个一个字符读的，可以看上面的十六进制文件，即“1”，“1”，“”4*，这一步操作主要是为了让他们连起来，变成一个字符串，然后根据字符串转成int型用来表示ASCII码值*)
let conv = tree_preat ls [] [] in(*预处理，为建树做准备*)
try treeprocess (conv) [] with(*建树*)
NullStack -> raise WuxiaoFile (*输入文件无效，即无法生成树，给出提示*)

;;


let rec changecharlist input_bits tree =
match tree with 
|Branch (k, Leaf, Leaf) -> k (*叶子结点则输出，这里的Leaf->[]*)
|Branch (k, l, r) -> let nextdata = getbit input_bits  in 
if not(nextdata)  then changecharlist input_bits l else
changecharlist input_bits r(*根据0、1串和哈夫曼树往下走，走到叶子结点输出，false走左子树，true走右子树*)
|_ -> '\n'
;;


let decode_write ic oc tree =
let newin = input_of_channel ic in  
let newin1 = input_bits_of_input newin in 
(*print_int newin.in_channel_length;*)
(*print_endline "_";*)
try 
while true do 
let char1 = changecharlist newin1 tree in
output_char oc char1
done
with 
End_of_file -> ()
;;

let decode infile outfile = 
let ic = open_in infile in
let oc = open_out outfile in
let decodetree = loadtree ic in
decode_write ic oc decodetree;
close_in ic; 
close_out oc; 
;;


decode (Sys.argv).(1) (Sys.argv).(2);;

