extends Control

# References to UI elements
@onready var ip_address_edit = $VBoxContainer/IPContainer/IPAddressEdit
@onready var port_edit = $VBoxContainer/PortContainer/PortEdit
@onready var send_lights_button = $VBoxContainer/SendLightsButton
@onready var custom_message_edit = $VBoxContainer/CustomContainer/CustomMessageEdit
@onready var send_custom_button = $VBoxContainer/SendCustomButton
@onready var status_label = $VBoxContainer/StatusLabel

# UDP socket
var udp_socket = PacketPeerUDP.new()

func _ready():
	# Set default values
	ip_address_edit.text = "192.168.1.100"
	port_edit.text = "8888"
	custom_message_edit.text = ""
	status_label.text = "Ready"
	status_label.modulate = Color.WHITE
	
	# Connect button signals
	send_lights_button.pressed.connect(_on_send_lights_pressed)
	send_custom_button.pressed.connect(_on_send_custom_pressed)

func send_udp_message(message: String):
	var ip_address = ip_address_edit.text
	var port = int(port_edit.text)
	
	if port <= 0 or port > 65535:
		status_label.text = "Error: Invalid port number"
		status_label.modulate = Color.RED
		return
	
	# Create a new UDP socket for each send
	var udp = PacketPeerUDP.new()
	udp.set_dest_address(ip_address, port)
	
	# Convert message to bytes and send
	var packet = message.to_utf8_buffer()
	var error = udp.put_packet(packet)
	
	if error == OK:
		status_label.text = 'Sent: "%s" to %s:%d' % [message, ip_address, port]
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "Error: Failed to send message (Error code: %d)" % error
		status_label.modulate = Color.RED
	
	udp.close()

func _on_send_lights_pressed():
	send_udp_message("lights_on")

func _on_send_custom_pressed():
	var message = custom_message_edit.text.strip_edges()
	
	if message.is_empty():
		status_label.text = "Error: Please enter a message to send"
		status_label.modulate = Color.RED
		return
	
	send_udp_message(message)
