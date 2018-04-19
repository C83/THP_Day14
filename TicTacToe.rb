require 'pry'

class Game

	def initialize
		puts "Bienvenue dans cette nouvelle partie de TicTacToe !"
		
		# Initialisation des joueurs 
		@players = []
		puts "----------- Joueur 1 -----------"
		@players.push(Player.new)
		puts "----------- Joueur 2 -----------"
		@players.push(Player.new)

		# Initialisation du plateau
		puts "C'est compris. Le joueur 1 est donc #{@players[0].name} et le joueur 2 est #{@players[1].name}"

		puts "Le plateau est de la forme suivante : "
		@board = Board.new
		@board.display(@players[0].name, @players[1].name)
		@winner = nil
		@nb_turn = 1
		puts "\nPour jouer, vous devrez indiquer la case sur laquelle vous voulez placer votre prochain coup."
		puts "Les colonnes sont désignées par des chiffres. Pour les lignes, ce sont des lettres."
		puts "Si vous voulez jouer en C2, vous devez donc écrire 'C2' ou bien '2C'"
		puts "\nVous êtes prêts ? Alors c'est parti !"
	end

	def run_game
		# Le while permet de recommencer le process chaque tour
		# Il y a deux raisons à l'arrêt de la partie : 
		# 	- soit il y a un gagnant 
		#   - soit neufs tours sont passés et il n'y a aucun gagant, c'est match nul
		while @winner == nil && (@nb_turn < 10) do
			puts "Tour #{@nb_turn}"
			
			# Permet de changer de joueur à chaque tour et de commencer par le joueur 1. Valeur possible : 0 ou 1
			index_player = (@nb_turn+1)%2
			
			# Demande à la personne de jouer
			purpose_play(index_player)
			# Le fait de tester d'abord nb_turn permet de ne pas faire win? avant qu'un joueur soit capable de gagner
			# puisque ruby ne réalise pas le second élément si la première condition d'un && est false
			# S'il y a un gagnant, on enregistre son index pour le féliciter ensuite
			@winner = index_player if (@nb_turn>4 && @board.win?(index_player) )
			# S'il n'y a pas encore de gagnant, je passe au tour suivant
			@nb_turn += 1 unless @winner 	# Pour ruby, une valeur nil correspond à un false. C'est pour cela que j'utilise unless
		end
		# On est en dehors de la boucle, la partie est finie. Il est temps d'indiquer s'il y a un gagnant ou si on termine sur un match nul
		if @winner != nil
			puts "Bravo, c'est #{@players[@winner].name} qui gagne. "
		else
			puts "C'est match nul pour cette fois. Relance donc une partie ! "
		end
	end
	

	# Méthode purpose_play
	# On demande quel est le prochain coup du joueur
	# @params : 
	# 	index_player : l'index du player en train de jouer
	# return : none

	def purpose_play (index_player)
		# Variables pour la méthode
		entry_ok = false
		entry = nil

		# On boucle tant que la réponse n'est pas adéquat ou que le coup ne peut pas être joué
		while entry == nil || !entry_ok
		 	puts "#{@players[index_player].name}, c'est à toi de jouer. Dans quelle case veux-tu jouer ton prochain coup ?"
		 	# Validate va vérifier que la réponse donnée commence bien par la description d'une case. 
		 	# S'il trouve le pattern attendu (C2 ou 2C), la méthode va réécrire la réponse pour qu'elle corresponde au format attendu (C2)
		 	# Si ce n'est pas le cas, elle renvoie nil
		 	# On n'oublie pas le upcase qui permet de ne pas avoir à gérer les minuscules / majuscules
		 	entry = validate ( gets.chomp.upcase)
		 	# si la réponse ne correspond pas à une case, on redemande directement. Sinon, on tente de placer le pion
		 	if (entry == nil) 
		 		puts("Mauvaise entrée. Ré-essaie\n\n")	# Deux \n car le puts annule le premier
		 	elsif (@board.place_pion(index_player, entry))	# Selon la définition de la fonction, la valeur retournée correspond à false s'il n'a pas été possible de placer le pion
				puts "C'est joué. Voici le plateau mis à jour :"
				entry_ok = true
		 	else
		 		puts "Case occupée, ré-essaie\n\n"
		 	end
		 end
		# Lance la méthode display une fois le coup enregistré
		display
	end

	 
	# Méthode validate
	# Retourne la réponse du joueur corrigée ou nil si la valeur n'est pas parmi celles attendues
	# @params : 
	# 	answer : string contenant la réponse du joueur
	# return : 
	# 	string avec la case valide si la réponse est conforme, nil sinon 

	def validate(answer)
		# On utilise un regex pour valider la réponse. Avec la regex renseignée, il faut que la réponse commence par une lettre puis un chiffre, ou un chiffre puis une lettre. 
		if answer.match('^[A-C][1-3]')
			# On retourne un string qui correspond à une case tel qu'on les manipule dans le programme
			return answer[0]+answer[1]
		elsif answer.match('^[1-3][A-C]')
			# Idem, on retourne un string corrigé
			return answer[1]+answer[0]
		else	
			# La valeur ne commence pas par la définition d'une case
			return nil
		end		
	end


	# Méthode display
	# Affiche le plateau de jeu

	def display
		@board.display(@players[0].name, @players[1].name)
	end
end

class Board
	attr_reader :board 	# Tableau contenant le jeu

	def initialize
		# Pour désigner une case : @board[i][j] avec i = ligne, j = colonne
		@board = Array.new(4, nil)
		@board.map! {|line| Array.new(4, nil)}
		
		# Utilisation des lignes et colonnes 0 pour l'affichage : 
		(1..3).each { |col| @board[0][col] = "#{col}" }
		(1..3).each {|line| @board[line][0] = (["A","B","C"][line-1])}
		@board[0][0] = " "

		# Initialisation des 9 BoardCase
		(1..3).each {|col|
				(1..3).each { |line|
					@board[line][col] = BoardCase.new
				}
		}
	end
	

	# Méthode display
	# Affiche le plateau de jeu
	
	def display (player_one_name = "1", player_two_name = "2")
		puts "Joueur #{player_one_name} : X \t Joueur #{player_two_name} : O"
		puts

		i = 0 
		# On met en place la présentation du plateau de jeu 
		@board.each { |line|
			puts "\t #{line[0]} | #{line[1].to_s} | #{line[2].to_s} | #{line[3].to_s}"
			puts "\t----------------" unless i == 3
			i += 1
		}
		puts
	end

 
	# Méthode place_pion
	# Place le pion sur la case spécifiée si celle-ci est libre
	# @params : 
	# 	index_player : l'index du joueur
	# 	selected_case : string contenant la case au bon format
	# return : 
	# 	boolean : true si le pion a bien été placé 

	def place_pion (index_player , selected_case)
		# On sélectionne la ligne désignée par la lettre
		case selected_case[0]
			when "A" then selected_line = 1
			when "B" then selected_line = 2
			else selected_line = 3
		end
		# On octroit la case à un joueur 
		action_done = @board[selected_line][selected_case[1].to_i].defined_case(index_player)
	end


	# Méthode win?
	# Vérifie si le joueur a gagné
	# @params : 
	# 	index_player : l'index du joueur
	# return : 
	# 	boolean : true si le joueur a gagné 

	def win? (index_player)
		# On commence par définir le symbole du joueur qu'on cherchera dans la valeur de la case
		symbol = index_player == 0 ? "X" : "O"
		a_winner = false

		# Il y a 8 manières de gagner. On check tous les cas
		if (
		# Teste ligne A, colonne 1 et diagonale si un pion du joueur se trouve en A1
		@board[1][1].value.include?(symbol)&&@board[1][2].value.include?(symbol)&&@board[1][3].value.include?(symbol) || 
		@board[1][1].value.include?(symbol)&&@board[2][1].value.include?(symbol)&&@board[3][1].value.include?(symbol) || 
		@board[1][1].value.include?(symbol)&&@board[2][2].value.include?(symbol)&&@board[3][3].value.include?(symbol) ||
		# Teste colonne 2 si un pion du joueur se trouve en A2
		@board[1][2].value.include?(symbol)&&@board[2][2].value.include?(symbol)&&@board[3][2].value.include?(symbol) ||
		# Teste colonne 3 si un pion du joueur se trouve en A3
		@board[1][3].value.include?(symbol)&&@board[2][3].value.include?(symbol)&&@board[3][3].value.include?(symbol) ||
		# Teste ligne B si un pion du joueur se trouve en B1
		@board[2][1].value.include?(symbol)&&@board[2][2].value.include?(symbol)&&@board[2][3].value.include?(symbol) ||
		# Test ligne C et diagonale si un pion du joueur se trouve en C1
		@board[3][1].value.include?(symbol)&&@board[3][2].value.include?(symbol)&&@board[3][3].value.include?(symbol) ||
		@board[3][1].value.include?(symbol)&&@board[2][2].value.include?(symbol)&&@board[1][3].value.include?(symbol) )
			a_winner = true
		end
	end
end

class Player
	attr_reader :name

	def initialize (predefined_name = nil)
		if predefined_name == nil
			puts "Quel est le nom du joueur ?"
			@name = gets.chomp.to_s
		else
			@name = predefined_name
		end
	end
end

class BoardCase
	attr_reader :value

	def initialize
		@value=" "
		@empty = false
	end


	# Méthode to_s
	# Renvoie un string contenant le nom du joueur
	# @params : none
	# return : 
	# 	string : contient le nom du joueur 

	def to_s
		return @value
	end


	# Méthode defined_case
	# Attribue le symbole du joueur dans la case
	# @params : player index
	# return : 
	# 	boolean : true si le symbole du player a été rajouté 

	def defined_case(player)
		return false if @empty == true

		@value = (player == 0) ? "X" : "O"
		@empty = true 	# Valeur retournée
	end
end

a = Game.new
a.run_game