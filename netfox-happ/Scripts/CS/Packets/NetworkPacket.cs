using Godot;
using System;
using System.Runtime.InteropServices;

public enum PacketType : byte {
	ping,               //debug packet
	i_join,             //I tell server I join
	someone_join,       //server tell me who joined/is in game
	setup_game,         //tell client what to load as they join
	ready_up,           //pre-game tells server ready. 
	start_game,         //starts match
	i_leave,
	someone_leave,

	// RPC Packets
	//rollback-synchronizer.gd
	_submit_inputs,     //Sends inputs by connection
	_submit_full_state,
	_submit_diff_state,
	_ack_full_state,
	_ack_diff_state,

	//network-tickrate-handshake.gd
	_submit_tickrate,
	//state-synchronizer.gd
	_submit_state__state_synchronizer,
	//rewindable-action.gd
	_submit_state__rewindable_action,
	//network-time.gd
	_submit_sync_success,
	//network-time-synchronizer.gd
	_send_ping,
	_send_pong,
	_request_timestamp,
	_set_timestamp,

	//From network weapons addon
	//network-weapon.gd
	_request_projectile,
	_accept_projectile,
	_decline_projectile

}

public static class PacketSerializerTool {
	/// <summary>
	/// Serializes packets, and sends them via the function call. 
	/// If this breaks, change the return type BACK to "IntPtr"
	/// </summary>
	/// <typeparam name="T"></typeparam>
	/// <param name="packet"></param>
	/// <param name="functionCall">transportLayer.SendNetworkTraffic</param>
	public static void SerializePacket<T>(T packet, Func<IntPtr, int, bool> functionCall) {
		IntPtr ptrData = Marshal.AllocHGlobal(Marshal.SizeOf(packet));
		Marshal.StructureToPtr(packet, ptrData, false);

		int sizeOfMessage = Marshal.SizeOf<T>(packet);

		functionCall(ptrData, sizeOfMessage);

		//return ptrData;
		Marshal.FreeHGlobal(ptrData);
	}

	public static PacketType CheckPacketType(IntPtr ptrData) {
		byte[] pingArray = new byte[sizeof(byte)];
		//byte[] pingArray = stackalloc byte[sizeof(byte)]; // Uses stack instead of heap. 
		Marshal.Copy(ptrData, pingArray, 0, 1);
		return (PacketType)pingArray[0];
	}

	public static void DeserializePacket<T>(IntPtr ptrData, int sizeOfMessage) { // change return type to T
		T packet;
		byte[] packetData = new byte[sizeOfMessage];

		Marshal.Copy(ptrData, packetData, 0, sizeOfMessage);

		// return packet;
	}

}

#region my packets

public struct PingPacket {
	public PacketType packet;
	PingPacket(PacketType packet) {
		this.packet = packet;
	}
}

public struct IJoinPacket {
	public PacketType packetType;
	public ulong myID;
}

public struct SomeoneJoinPacket {
	public PacketType packetType;
	public double playerID;
	public string playerName;
}

public struct SetupGamePacket {
	public PacketType packetType;
	//public GameMode gameMode;
}

public struct ReadyUpPacket {
	public PacketType packetType;
}

public struct StartGamePacket {
	public PacketType packetType;
}

public struct ILeavePacket {
	public PacketType packetType;
}

public struct SomeoneLeavePacket {
	public PacketType packetType;
}

#endregion


#region netfox packets

public struct InputPacket {
	public PacketType packetType;
	//public Input? inputData; // May need to convert to Struct for "unsafe memory" compatibility. 
	string key;
	Vector3[] value;

	public uint frame;
}

#endregion