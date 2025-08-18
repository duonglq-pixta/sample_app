# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
puts "Clearing existing data..."
User.destroy_all
Micropost.destroy_all

# Create sample users
puts "Creating sample users..."

users = [
  {
    name: "John Doe",
    email: "john@example.com",
    password: "password123",
    activated: true,
    activated_at: Time.zone.now
  },
  {
    name: "Jane Smith",
    email: "jane@example.com", 
    password: "password123",
    activated: true,
    activated_at: Time.zone.now
  },
  {
    name: "Bob Johnson",
    email: "bob@example.com",
    password: "password123", 
    activated: true,
    activated_at: Time.zone.now
  },
  {
    name: "Alice Brown",
    email: "alice@example.com",
    password: "password123",
    activated: true,
    activated_at: Time.zone.now
  },
  {
    name: "Charlie Wilson",
    email: "charlie@example.com",
    password: "password123",
    activated: true,
    activated_at: Time.zone.now
  }
]

created_users = []
users.each do |user_attrs|
  user = User.create!(user_attrs)
  created_users << user
  puts "Created user: #{user.name} (#{user.email})"
end

# Create sample microposts
puts "Creating sample microposts..."

micropost_contents = [
  "Just finished reading an amazing book about web development! 📚 #coding #learning",
  "Beautiful day for a walk in the park. Nature is truly inspiring! 🌳",
  "Working on a new Rails project. The framework is so elegant and powerful! 💻",
  "Coffee and coding - the perfect combination for productivity! ☕",
  "Excited to learn more about Ruby on Rails. The community is so helpful! 🚀",
  "Just deployed my first Rails app to production. What a feeling! 🎉",
  "The weather is perfect today. Time to enjoy some outdoor activities! ☀️",
  "Learning about database design and relationships. So fascinating! 🗄️",
  "Had a great conversation with fellow developers today. Networking is key! 👥",
  "Working on improving my coding skills. Practice makes perfect! 💪",
  "Just discovered a new gem that makes development so much easier! 💎",
  "The sunset tonight was absolutely breathtaking! Nature's beauty never fails to amaze. 🌅",
  "Debugging can be frustrating, but solving problems is so rewarding! 🔍",
  "Reading about software architecture patterns. Knowledge is power! 📖",
  "Time to refactor some old code. Clean code is maintainable code! ✨",
  "Just learned about test-driven development. It's a game changer! 🧪",
  "The weekend is here! Time to relax and recharge. 😌",
  "Working on a new feature. The satisfaction of building something useful is incredible! 🛠️",
  "Just joined a coding meetup. Community is everything in tech! 🤝",
  "Learning about API design. RESTful principles are so important! 🌐"
]

# Create microposts for each user with different timestamps
created_users.each_with_index do |user, user_index|
  # Each user gets 3-5 microposts
  num_posts = rand(3..5)
  
  num_posts.times do |post_index|
    # Create posts with different timestamps (within the last 30 days)
    created_at = Time.zone.now - rand(0..30).days - rand(0..23).hours - rand(0..59).minutes
    
    content = micropost_contents.sample
    
    micropost = user.microposts.create!(
      content: content,
      created_at: created_at,
      updated_at: created_at
    )
    
    puts "Created micropost for #{user.name}: '#{content[0..50]}...'"
  end
end

puts "Seed data created successfully!"
puts "Total users created: #{User.count}"
puts "Total microposts created: #{Micropost.count}"
