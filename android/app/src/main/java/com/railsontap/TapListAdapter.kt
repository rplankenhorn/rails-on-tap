package com.railsontap

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ProgressBar
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView

class TapListAdapter(
    private val onTapClick: (Tap) -> Unit
) : ListAdapter<Tap, TapListAdapter.TapViewHolder>(TapDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): TapViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_tap, parent, false)
        return TapViewHolder(view, onTapClick)
    }

    override fun onBindViewHolder(holder: TapViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    class TapViewHolder(
        itemView: View,
        private val onTapClick: (Tap) -> Unit
    ) : RecyclerView.ViewHolder(itemView) {
        private val nameText: TextView = itemView.findViewById(R.id.tap_name)
        private val beverageText: TextView = itemView.findViewById(R.id.beverage_name)
        private val producerText: TextView = itemView.findViewById(R.id.producer_name)
        private val progressBar: ProgressBar = itemView.findViewById(R.id.keg_progress)
        private val percentText: TextView = itemView.findViewById(R.id.percent_text)

        fun bind(tap: Tap) {
            nameText.text = tap.name
            beverageText.text = tap.beverageType
            producerText.text = tap.producer
            progressBar.progress = tap.percentFull.toInt()
            percentText.text = "${tap.percentFull.toInt()}%"
            
            itemView.setOnClickListener {
                onTapClick(tap)
            }
        }
    }

    private class TapDiffCallback : DiffUtil.ItemCallback<Tap>() {
        override fun areItemsTheSame(oldItem: Tap, newItem: Tap): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Tap, newItem: Tap): Boolean {
            return oldItem == newItem
        }
    }
}
