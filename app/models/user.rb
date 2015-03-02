class User < ActiveRecord::Base
	#follow a user
	def follow!(user)
		#multi makes this set of operations atomic 
		$redis.multi do
			$redis.sadd(self.redis_key(:following), user.id)
			$redis.sadd(user.redis_key(:followers), self.id)
		end
	end

	#unfollow a user
	def unfollow! (user)
		$redis.multi do
			$redis.srem(self.redis_key(:following), user.id)
			$redis.srem(self.redis_key(:followers), self.id)
		end
	end

	def followers
		#smembers will return all the values in the set stored with that key
		user_ids = $redis.smembers(self.redis_key(:followers))
		#user_ids will contain a list of all the users that self's followers
		User.where(id: user_ids)
	end

	def following
		user_ids = $reids.smembers(self.redis_key(:following))
		User.where(id: user_ids)
	end

	def freinds
		#sinter retunrs the comon values of the intersection of the two sets
		user_ids = $redis.sinter(self.redis_key(:followers), self.redis_key(:following))
		User.where(id: user_ids)
	end

	def following?(user)
		#returs a boolean if user.id is a values with the set at the key :following
		$redis.sismember(self.redis_key(:following), user.id)
	end

	def follower?(user)
		$redis.sismember(self.redis_key(:followers), user.id)
	end

	def followers_count
		#returns a count of the members inside the set with that key 
    	$redis.scard(self.redis_key(:followers))
  	end

  	def following_count
    	$redis.scard(self.redis_key(:following))
  	end

  	#helper method used to generate custom redis keys
  	def redis_key(str)
  		"user:#{self.id}:#{str}"
  	end


end
