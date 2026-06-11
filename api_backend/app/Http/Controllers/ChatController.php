<?php

namespace App\Http\Controllers;

use App\Models\Chat;
use App\Models\Message;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    // User: get or create their chat
    public function userChat(Request $request)
    {
        $chat = Chat::firstOrCreate([
            'user_id' => $request->user()->id,
        ]);

        $unreadCount = Message::where('chat_id', $chat->id)
            ->where('sender_id', '!=', $request->user()->id)
            ->where('read', false)
            ->count();

        return response()->json([
            'chat' => $chat->load('lastMessage'),
            'unread_count' => $unreadCount,
        ]);
    }

    // User: get messages
    public function messages(Request $request, $chatId)
    {
        $chat = Chat::where('user_id', $request->user()->id)
            ->where('id', $chatId)
            ->firstOrFail();

        $messages = Message::where('chat_id', $chatId)
            ->with('sender:id,name,role')
            ->latest()
            ->limit(50)
            ->get()
            ->reverse()
            ->values();

        return response()->json(['messages' => $messages]);
    }

    // User: send message
    public function sendMessage(Request $request, $chatId)
    {
        $chat = Chat::where('user_id', $request->user()->id)
            ->where('id', $chatId)
            ->firstOrFail();

        $request->validate([
            'message' => 'required|string',
        ]);

        $message = Message::create([
            'chat_id' => $chatId,
            'sender_id' => $request->user()->id,
            'message' => $request->message,
        ]);

        return response()->json($message->load('sender:id,name,role'), 201);
    }

    // Admin: get all chats
    public function adminChats()
    {
        $chats = Chat::with(['user:id,name', 'lastMessage'])
            ->latest()
            ->get()
            ->map(function ($chat) {
                $chat->unread_count = Message::where('chat_id', $chat->id)
                    ->where('sender_id', $chat->user_id)
                    ->where('read', false)
                    ->count();
                return $chat;
            });

        return response()->json(['chats' => $chats]);
    }

    // Admin: get messages for a chat
    public function adminMessages($chatId)
    {
        $messages = Message::where('chat_id', $chatId)
            ->with('sender:id,name,role')
            ->latest()
            ->limit(50)
            ->get()
            ->reverse()
            ->values();

        return response()->json(['messages' => $messages]);
    }

    // Admin: send message
    public function adminSendMessage(Request $request, $chatId)
    {
        $chat = Chat::findOrFail($chatId);
        $chat->update(['admin_id' => $request->user()->id]);

        $request->validate([
            'message' => 'required|string',
        ]);

        $message = Message::create([
            'chat_id' => $chatId,
            'sender_id' => $request->user()->id,
            'message' => $request->message,
            'read' => false,
        ]);

        return response()->json($message->load('sender:id,name,role'), 201);
    }

    // Mark messages as read
    public function markAsRead(Request $request, $chatId)
    {
        Message::where('chat_id', $chatId)
            ->where('sender_id', '!=', $request->user()->id)
            ->where('read', false)
            ->update(['read' => true]);

        return response()->json(['message' => 'Messages marked as read']);
    }
}
