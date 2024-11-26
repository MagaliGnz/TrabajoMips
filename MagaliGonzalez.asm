.data
slist: .word 0 #lista de bloques libres
cclist: .word 0 #lista de categorias
wclist: .word 0 #categoria actual 
schedv: .space 32
menu: .ascii "Colecciones de objetos categorizados\n"
.ascii "====================================\n"
.ascii "1-Nueva categoria\n"
.ascii "2-Siguiente categoria\n"
.ascii "3-Categoria anterior\n"
.ascii "4-Listar categorias\n"
.ascii "5-Borrar categoria actual\n"
.ascii "6-Anexar objeto a la categoria actual\n"
.ascii "7-Listar objetos de la categoria\n"
.ascii "8-Borrar objeto de la categoria\n"
.ascii "0-Salir\n"
.asciiz "Ingrese la opcion deseada: "
error: .asciiz "Error: "
continueMsg: .asciiz "\n¿Desea agregar otro objeto? (1 = sí, 0 = no): "
errorMsg: .asciiz "\nLa opcion ingresada es incorrecta" 
emptyListMsg: .asciiz"\nLa lista está vacía"
return: .asciiz "\n"
tab: .asciiz "\t"                 
catName: .asciiz "\nIngrese el nombre de una categoria: "
selCat: .asciiz "\nSe ha seleccionado la categoria:"
noCategories: .asciiz "\nNo hay categorias en la lista"
idObj: .asciiz "\nIngrese el ID del objeto a eliminar: "
notFound: .asciiz "\nID no encontrado. "
noObjects: .asciiz   "\nNo hay objetos en la lista."
objName: .asciiz "\nIngrese el nombre de un objeto: "
success: .asciiz "La operación se realizo con exito\n\n"

.text
.globl main
#----------

main: 	la 	$t0, schedv	 #carga la direccion de schedv en en $t0
	
	
	#cargar funciones en schedv
	   li    $t1, 0
   	  sw    $t1, cclist      		 # Inicializa cclist como vacía
  	  sw    $t1, wclist      		 # Inicializa wclist como vacía

	
 	 la 	$t1, newcaterogy  	 #carga la direccion de la funcion nwCat 
	 sw 	$t1, 0($t0)  		 # guardar &(schedv[0])
	
	 la  $t1, nextCategory   	 # dirección de la función nextCategory
    	 sw  $t1, 4($t0)          		# schedv[2] = nextCategory

	 la  $t1, prevCategory    	# Dirección de la función prevCategory
	 sw  $t1, 8($t0)         		# schedv[3] = prevCategory
	 
	 la	$t1, listCategories	 # Dirección de la función listCategories
	 sw	$t1, 12($t0)		 # schedv[4] = listCategories
	 
	 la	$t1, deleteCategory	#Direccion de la funcion deleteCategory
	 sw	$t1, 16($t0)		#schedv[5] = deleteCategory
	 
	 la	$t1, newObject	#Direccion de la funcion newObjects
	 sw	$t1, 20($t0)		#schedv[6] = newObjects
	 
	 la	$t1, listObjects	#direccion de listObjects
	 sw	$t1, 24($t0)		#schedv[7] = listObjects
	 
	 la	$t1, deleteObject	#direccion de deleteObject
	 sw	$t1, 28($t0)		#schedv[8]) = deleteObject
	 
	#-----------------------------
	
  	  
  	  j	menuLoop
  	  j	end 

menuLoop:
  	 la    $a0, menu         			 # mostrar el menú
	 li    $v0, 4
   	 syscall

  	 li    $v0, 5             			# leer la opción seleccionada
 	 syscall
   	 move  $a0, $v0           		# pasar la opción a $a0
   	 

    	beq   $a0, 0, end        		# si la opción es 0, terminar
    	subi  $a0, $a0, 1        		# ajustar índice (opción 1 = índice 0)
    	
    	#validar que la opcion sea valida
   	
   	li	$t1, 8				#numero de opciones en el menu -1
   	blt 	$a0, $zero, menuLoop	#si a0 < 0, return menu
   	bge 	$a0, $t1, menuLoop		#si a0 >= numero de funciones, repetir menu
   	
   	
   	# llamar a una funcion del schedv, $t0 = id de la funcion
    	 la    	 $t1, schedv        # Dirección base del vector
      	 sll   	 $t2, $a0, 2        # t2 = t0 * 4 (tamaño de una palabra)
      	 add   	 $t3, $t1, $t2      # Dirección de la entrada correspondiente
    	 lw   	 $t4, 0($t3)         # Cargar dirección de la función en t4

       
   	 jalr    	$t4            
   	 j     menuLoop          # Repetir el menú

#----------

smalloc:
	lw 	$t0, slist #lista NULL en t0
	beqz 	$t0, sbrk  #si slist = 0, salta a la funcion sbrk
	move 	$v0, $t0	#copia slist en v0
	lw 	$t0, 12($t0) #t0 = slist [0]->[3] (12/4)
	sw 	$t0, slist  # mueve el inicio de slist para que inicialice en lo que antes era pos3
	jr 	$ra #resturn
sbrk: 
	li 	$a0, 16 # pide un espacio de 4 palabras
	li 	$v0, 9 # 9 = sbrk
	syscall # return node address in v0
	jr 	$ra
sfree: #recibe la direccion de una memoria a liberar
	lw 	$t0, slist #guarda slist en t0
	sw 	$t0, 12($a0) #ubica el inicio de slist al final de a0 
	sw 	$a0, slist #slist arranque desde el inicio de a0
	jr 	$ra

newcaterogy:
	addiu 	$sp, $sp, -4 #mueve una posicion adelante
	sw 	$ra, 4($sp) #guarda el return adress de newcategory en la pila para poder retornar mas tarde ya que ra va a cambiar de valor 
	la 	$a0, catName # argumento para getblock
	jal 	getblock #scanf
	
	move 	$a2, $v0 # mueve el retorno de getblock a a2
	la 	$a0, cclist # carga la lista de las categorias en a0
	li	 $a1, 0 # $a1 = NULL
	
	jal 	addnode #agrega un nodo
	lw 	$t0, wclist #carga en t0 la categoria actual
	bnez 	$t0, newcategory_end #si t0 = 0 ejecuta newcategory_end
	sw 	$v0, wclist # guarda la categoria seleccionada en v0 si t0 != 0 
newcategory_end:
	li 	$v0, 0 # return success
	lw 	$ra, 4($sp) #restaura la dir de retorno original de la funcion 
	addiu 	$sp, $sp, 4 #devuelvo memoria
	jr 	$ra

# a0: list address
# a1: NULL if category, node address if object
# v0: node address added
addnode:
	addi	$sp, $sp, -8 #mueve 2 posiciones dentro del stack pointer
	sw 	$ra, 8($sp) #almacena ra en la ultima posicion del sp
	sw	$a0, 4($sp) #almacena a0 en la primera posicion del sp
	jal smalloc 
	
	sw 	$a1, 4($v0) # guarda a a1 en v0 siguiente
	sw 	$a2, 8($v0) # v0 siguiente siguiente
	lw 	$a0, 4($sp) #restaura a0
	lw 	$t0, ($a0) # guarda en t0 el inicio de la lista
	beqz 	$t0, addnode_empty_list #si t0 = 0 inicializa addnode_empty_list
	
addnode_to_end:
	lw	 $t1, ($t0)		 # last node address
	# update prev and next pointers of new node
	sw	 $t1, 0($v0)
	sw 	 $t0, 12($v0)
	# update prev and first node to new node
	sw 	$v0, 12($t1)
	sw 	$v0, 0($t0)
j addnode_exit
addnode_empty_list: 		#agrega un nodo cuando la lista esta vacia
	sw 	$v0, ($a0)
	sw 	$v0, 0($v0)
	sw 	$v0, 12($v0)
addnode_exit: #retorno
	lw 	$ra, 8($sp)
	addi 	$sp, $sp, 8
	jr 	$ra
# a0: direccion del nodo a borrar
# a1: la lista de donde borrar el nodo 
delnode:
	addi 	$sp, $sp, -8 		#reserva 2 espacios en el stack pointer 
	sw 	$ra, 8($sp) 		#final del sp
	sw 	$a0, 4($sp)		 #principio del sp
	lw 	$a0, 8($a0) 		# selecciona el nodo a borrar dentro de la lista
	jal	sfree # free block
	lw 	$a0, 4($sp) 		# restore argument a0
	lw 	$t0, 12($a0)		 # carga en t0 la posicion del sig nodo 
node:
	beq 	$a0, $t0, delnode_point_self #si el nodo a liberar es igual al siguiente saltea a delnode_point_self 
	lw 	$t1, 0($a0) 		# carga en t1 la direccion del nodo anterior
	sw 	$t1, 0($t0) 		# guarda la direccion del nodo anterior en la direccion anterior del nodo siguiente (Nodsig)
	sw 	$t0, 12($t1) 		# guarda direccion Nodsig en la direccion siguiente del nodo anterior 
	lw 	$t1, 0($a1) 		# carga el primer elemento de la lista en t1
again:
	bne 	$a0, $t1, delnode_exit #si el nodo a borrar es desigual a el primer elemento de la lista llama a delnode_exit
	sw 	$t0, ($a1)		 # guarda el nodo siguiente en el inicio de la lista 
	j delnode_exit 
delnode_point_self:
	sw 	$zero, ($a1) 		# only one node
	j	delnode_exit
delnode_exit:
	jal sfree
	lw 	$ra, 8($sp)
	addi 	$sp, $sp, 8
	jr 	$ra

# a0: msg to ask
# v0: block address allocated with string
getblock: #scanf glorificado
	addi 	$sp, $sp, -4 		#pido memoria
	sw 	$ra, 4($sp)
	li 	$v0, 4
	syscall
	jal smalloc
	move 	$a0, $v0
	li 	$a1, 16		 #maxima cant de caracteres
	li 	$v0, 8 			#scanf
	syscall
	move	$v0, $a0 		#retorna el valor ingresado por el usuario
	lw 	$ra, 4($sp)		 #restaura la dir de retorno original de la funcion getblock
	addi 	$sp, $sp, 4 		#devuelvo memoria
	jr 	$ra
	
#base para el error	
printError:
		li $v0, 4

		la $a0, error
		syscall
		
		
		move $a0, $a1
		li  $v0, 1
		syscall

		la $a0, return
		li  $v0, 4
		syscall

		jr $ra
		
	
#------------------------
#2
nextCategory: 
		
		addi    $sp, $sp, -4   			#reservo espacio en la pila 
   		sw   	$ra, 4($sp)			#guardar el return adress
   		
   		
		lw 	$t0, wclist  			#cargar categoria actual
		li	$a1, 201
		beqz   $t0, printError			#error si no hay categoria
		
		
		
		lw 	$t1, 12($t0)  			#siguiente categoria (siguiente casilla 4= 12)
		li	$a1, 202
		beq     $t0,  $t1, printError  		#si t0 = t1, error autorreferenciado 
		
		sw 	$t1, wclist			#actualizo la categoria actual  
		la 	$a0, selCat			#cargo el mensaje de categoria seleccionada
		li	$v0, 4		
		syscall
		  
	
		lw 	$a0, 8($t1)     		 #cargar el nombre de la categoriaSeleccionada (nombre casiila 3=8)
		li 	$v0, 4				#printf
		syscall
		
		lw 	$ra, 4($sp)	
 		addi    $sp, $sp, 4 			#limpio el stack
		jr 	$ra 				#RETURN
					
				
		
	
	
prevCategory: 
		
		addi    $sp, $sp, -4  			 #reservo espacio en la pila 
   		sw   	$ra, 4($sp)			#guardar el return adress
   		
		lw 	$t0, wclist  			#cargar categoria actual
		li	$a1, 201	
		beqz   $t0, printError			#error si no hay categoria
		
		
		lw 	$t1, 0($t0)  			#anterior categoria (0)
		li 	$a1, 202			#carga inmediata
		beq     $t0, $t1, printError 		#si hay una sola categoria, error202
		
		sw 	$t1, wclist			#actualizo la categoria actual  
		la 	$a0, selCat			#cargo el mensaje de categoria seleccionada
		li	$v0, 4		
		syscall
		  
		lw 	$a0, 8($t1)      		#cargar el nombre de la categoriaSeleccionada (nombre casiila 3=8)
		li 	$v0, 4				#printf
		syscall
		
		lw 	$ra, 4($sp)	
 		addi    $sp, $sp, 4 			#limpio el stack
		jr 	$ra 				#RETURN
		
		
		
		

#-------------------------------------------------------
#3
listCategories:
		addi    $sp, $sp, -4  			 #reservo espacio en la pila 
   		sw   	$ra, 4($sp)			#guardar el return adress
   		
   		lw	$t0, cclist			#cargo la lista de categorias
   		li	$a0, 301
   		beqz   $t0, printError
   		
   		move	$t1, 	$t0			#apunto al primer nodo
   		
   		
   	
 listCategoriesLoop:
 		la	$a0, return			#salto de linea
 		li	$v0, 4		
 		syscall
 		
 		lw	$a0, 8($t0)			#cargar la cateogoria de nombre
 		li	$v0, 4
 		syscall
 		
 		la	$a0, return			#salto de linea
 		li	$v0, 4		
 		syscall
 		
 		
 		lw	$t0, 12($t0)			#cargar el nodo siguiente
 		bne     $t0, $t1, listCategoriesLoop # continuo mientras no regrese al inicio
 		
 		j	listCategoryEnd
 		
		
listCategoryEnd: 

		lw 	$ra, 4($sp)	
 		addi    $sp, $sp, 4 			#limpio el stack
		jr 	$ra 				#RETURN
		


#-------------------
#4

deleteCategory:
		
		addi    $sp, $sp, -8   			#reservo espacio en la pila 
   		sw   	$ra, 8($sp)			#guardar el return adress
   		sw	$s0, 4($sp)			#reservo s0 para la categoria actual
   		
   		lw	$s0, wclist			#cargo la categoria actual
   		li	$a0, 401
   		beqz   $s0, printError

		#cargar la lista de objetos de la categoria
		lw	$t2, 4($s0)			#cargo la &(objetos)
		beqz	$t2, deleteCurrentCategory	#si la lista de objetos esta vacia
		
		#si la lista de objetos no esta vacia, eliminar todos los objetos
		
deleteObjectsLoop:
		lw	$t2, 4($s0)
		move	$t3, $t2			#paso la direccion de la lista de objetos
		lw	$t2, 12($t3)			#cargar el siguiente nodo
		
		
		#eliminar el nodo actual
		move	$a0, $t3			#pasar la direccion de la categoria a eliminar
		la	$a1, 4($s0)
		jal	delnode			#eliminar la categoria
		
		
		bne	$t2, $t3,	deleteObjectsLoop	#si no son iguales, continua el loop
		
		
deleteCurrentCategory:
		#eliminar la categoria despues de vaciar la lista
		move 	$a0, $s0
		la	$a1, cclist
		jal 	delnode
		
		#mensaje de exito
		la	$a0, success	
		li	$v0, 4
		syscall
		
		#si no hay mas categorias, nulificar los punteros
		lw	$t1, cclist			#verifico si hay mas categorias
		beqz	$t1, noMoreCategories
		sw	$t1, wclist
		
		
		j	deleteCategoryEnd		#salir de la funcion

noMoreCategories:
		sw	$zero, wclist			#nulificar punteros si no hay mas categorias
		la	$a0, noCategories
		li 	$v0, 4
		syscall
		j	deleteCategoryEnd
		
		

deleteCategoryEnd:
		sw	$s0, 4($sp)
		lw 	$ra, 8($sp)	
 		addi    $sp, $sp, 8 			#limpio el stack
		jr 	$ra 				#RETURN
		
		

#----------------------
#5
							
								

newObject:
		addi    $sp, $sp, -8     		 # reservo espacio en la pila para almacenar registros
   		sw      $ra, 8($sp)        		 # guardo el return address
   		sw	$s0, 4($sp)			#guardo el puntero a la categoria
   	
 newObjectLoop:
    		
		lw	$s0, wclist			#cargo la cateogira actual
		li	$a0, 501			#cargo directa para el tipo de error
		beqz	$s0, printError	
		
		#obtener nombre del objeto
		
		la 	$a0, objName		 # argumento para getblock
		jal 	getblock 			#scanf
		move 	$a2, $v0 			# mueve el retorno de getblock a a2
		
		#obtener el siguiente id disponible
		lw	$a0, 4($s0)			#cargar la direccion del primer nodo
		jal	getNextID			#llamada a nextID
		move	$a1, $v0			#guarda el siguiente id en a1
		
		#agrego un nodo a la categoria(objeto)
		la	$a0, 4($s0)			#cargar la direccion del primer nodo
		jal	addnode	
	
		#-----------------------------------------------------------------------------------
		# preguntar si desea agregar otro objeto
		la	$a0, continueMsg		 
		li	$v0, 4			 
		syscall

		li	$v0, 5				 #leer un entero
		syscall
		move	$t5 ,$v0			#mover el valor ingresado a $t5
		
		
		beqz	$t5, newObjectExit
		li	$t6, 	1
		beq	$t5, $t6, newObjectLoop
		
		#si el valor no es ni 0 ni 1
		
		la	$a0, errorMsg
		li	$v0, 4
		syscall
		j	 newObjectLoop
		
newObjectExit:
		li 	$v0, 0		 		#return success 
		lw	$s0, 4($sp)
		lw 	$ra, 8($sp) 			#restaura la dir de retorno original de la funcion 
		addiu 	$sp, $sp, 8 			#devuelvo memoria
		jr 	$ra   
				
		
	# función para obtener el siguiente ID disponible
getNextID:
    	# entrada: $a0 = dirección del primer nodo de la lista
    
   		 li      $v0, 1            			# inicializa ID a 1 (en caso de que la lista esté vacía)
    
   		 beqz    $a0, getNextID_exit  	# Si la lista está vacía, ID es 1 (salta)
   		 
    
  		  move    $t0, $a0          		# poner el primer nodo en $t0
  		  lw	$t2, 4($t0)			#cargar el id del primer nodo en $v1
    
findLastNode:
  		  lw      $t1, 12($t0)       		# cargo puntero siguiente del nodo actual
  		  beq 	$t1, $a0, foundLastNode  	# si el siguiente nodo es NULL, encontre el ultimo nodo
  		  move    $t0, $t1          		# avanzo al siguiente nodo
  		  lw	$t2, 4($t0)			#actualizo $t2 con el id del nodo actual
		    j       findLastNode

foundLastNode:
 		
		 addiu   $v0, $t2, 1      		 # incremento el ID del ultimo nodo en 1
		   
getNextID_exit:
			 jr      $ra              	 

#-----------------------------
 #6			 

listObjects:
		addi    $sp, $sp, -4   			#reservo espacio en la pila 
   		sw   	$ra, 4($sp)			#guardar el return adress
   		
   		lw	$t0, wclist			#cargo la categoria actual
   		li	$a0, 601			#error 601 si no hay categorias
   		beqz   $t0, printError
   		
   		lw	$t2, 4($t0)			#cargar la lista de objetos 
   		li	$a0, 602			#error 602 no hay objetos
   		beqz	$t2, printError
   		
   		#listar los objetos
   		move	$t3, $t2			#apunto al primer nodo de categorias
   		move	$t4, $t3 			#guardar el inicio de la lista de objetos
   		
 		
listObjectsLoop:

		la	$a0, tab			#imprimir tabulador
		li	$v0, 4
		syscall
		
		lw	$a0, 4($t3)			#imprimir id
		li	$v0, 1
		syscall
		
		
		lw	$a0, 8($t3)			#cargo el nombre del objeto
		li 	$v0,  4		
		syscall
		

		
		lw	$t3, 12($t3)			#cargar el siguiente nodo de objetos
		bne	$t3, $t4, listObjectsLoop
		
		j	listObjectsEnd		#salir de la funcion
 		
 		
		
listObjectsEnd: 

		lw 	$ra, 4($sp)	
 		addi    $sp, $sp, 4 			#limpio el stack
		jr 	$ra 				#RETURN
		
#-----------------------------
#7

deleteObject:
		addi    $sp, $sp, -4  			 #reservo espacio en la pila 
   		sw   	$ra, 4($sp)			#guardar el return adress
   		
		lw	$t0, wclist			#cargo la categoria actual
   		li	$a0, 701			#error 701 si no hay categorias
   		beqz   $t0, printError
   		
   		
   		lw	$t2, 4($t0)			#cargar la lista de objetos 
   		beqz	$t2, handleNoObjects
   		
   		#pedir la id al usuario
   		la	$a0, idObj		
   		li	$v0, 4
   		syscall
   		
   		li	$v0, 5				#leer un entero
   		syscall
   		move	$t5, $v0			#guardar id ingresado en t5
   		
   		
   		#listar los objetos
   		move	$t3, $t2			#apunto al primer nodo de categorias
   		move	$t4, $t3 			#guardar el inicio de la lista de objetos
   			
findObjectIDLoop:
		lw	$t6, 4($t3)			#cargar el id del nodo actual
		beq	$t6, $t5, deleteFound	#si el ID coincide, saltar a la eliminacion
		
		#avanzo al siguiente nodo
		lw	$t3, 12($t3)			
		bne	$t3, $t4, findObjectIDLoop	
		
		#no se encontro el objeto
		la	$a0, notFound	
		li	$v0, 4
		syscall
		j	deleteObjectEnd					


 deleteFound:
		#llamar a delnode para eliminar el nodo
		la	$a1, 4($t0)			#cargo la direccion del id
		move	$a0, $t3			#pasar la direccion del nodo a eliminar
		jal	delnode
		
		#mensaje de confirmacion
		la	$a0, success
		li	$v0, 4
		syscall
		j	deleteObjectEnd

		
handleNoObjects:
   		 # manejar caso de lista vacía
    		la      $a0, noObjects     		# mensaje: "No hay objetos en la lista."
    		li      $v0, 4           			# Print string
   		 syscall
 		  j       deleteObjectEnd    		# salir de la función
					
deleteObjectEnd:					
		lw 	$ra, 4($sp)	
 		addi    $sp, $sp, 4 			#limpio el stack
		jr 	$ra 				#RETURN
		
																				
																																								
end: 		li 	$v0, 10
		syscall

