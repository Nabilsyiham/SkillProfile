<?php

namespace App\Http\Controllers;

use App\Models\Address;
use Illuminate\Http\Request;

class AddressController extends Controller
{
    public function index(Request $request)
    {
        $addresses = Address::where('user_id', $request->user()->id)
            ->orderByDesc('is_default')
            ->orderByDesc('updated_at')
            ->get();
        return response()->json(['addresses' => $addresses]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'label' => 'required|string|max:50',
            'recipient_name' => 'required|string|max:100',
            'phone' => 'required|string|max:20',
            'address' => 'required|string',
            'city' => 'required|string|max:100',
            'province' => 'required|string|max:100',
            'postal_code' => 'nullable|string|max:10',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_default' => 'boolean',
        ]);

        if ($request->is_default) {
            Address::where('user_id', $request->user()->id)
                ->where('is_default', true)
                ->update(['is_default' => false]);
        }

        $addressCount = Address::where('user_id', $request->user()->id)->count();
        if ($addressCount === 0) {
            $request->merge(['is_default' => true]);
        }

        $address = Address::create([
            'user_id' => $request->user()->id,
            'label' => $request->label,
            'recipient_name' => $request->recipient_name,
            'phone' => $request->phone,
            'address' => $request->address,
            'city' => $request->city,
            'province' => $request->province,
            'postal_code' => $request->postal_code,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'is_default' => $request->is_default ?? false,
        ]);

        return response()->json(['address' => $address], 201);
    }

    public function update(Request $request, $id)
    {
        $address = Address::where('user_id', $request->user()->id)->findOrFail($id);

        $request->validate([
            'label' => 'required|string|max:50',
            'recipient_name' => 'required|string|max:100',
            'phone' => 'required|string|max:20',
            'address' => 'required|string',
            'city' => 'required|string|max:100',
            'province' => 'required|string|max:100',
            'postal_code' => 'nullable|string|max:10',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_default' => 'boolean',
        ]);

        if ($request->is_default) {
            Address::where('user_id', $request->user()->id)
                ->where('id', '!=', $id)
                ->update(['is_default' => false]);
        }

        $address->update($request->only([
            'label', 'recipient_name', 'phone', 'address',
            'city', 'province', 'postal_code',
            'latitude', 'longitude', 'is_default',
        ]));

        return response()->json(['address' => $address]);
    }

    public function destroy(Request $request, $id)
    {
        $address = Address::where('user_id', $request->user()->id)->findOrFail($id);
        $wasDefault = $address->is_default;
        $address->delete();

        if ($wasDefault) {
            $mostRecent = Address::where('user_id', $request->user()->id)
                ->latest()
                ->first();
            if ($mostRecent) {
                $mostRecent->update(['is_default' => true]);
            }
        }

        return response()->json(['message' => 'Address deleted']);
    }

    public function setDefault(Request $request, $id)
    {
        $address = Address::where('user_id', $request->user()->id)->findOrFail($id);

        Address::where('user_id', $request->user()->id)
            ->update(['is_default' => false]);

        $address->update(['is_default' => true]);

        return response()->json(['message' => 'Default address updated']);
    }
}
