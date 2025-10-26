package com.railsontap

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView

class RecentPoursAdapter : ListAdapter<Pour, RecentPoursAdapter.PourViewHolder>(PourDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PourViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_recent_pour, parent, false)
        return PourViewHolder(view)
    }

    override fun onBindViewHolder(holder: PourViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    class PourViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val thumbnailImage: ImageView = itemView.findViewById(R.id.pour_thumbnail)
        private val userText: TextView = itemView.findViewById(R.id.pour_user)
        private val beverageText: TextView = itemView.findViewById(R.id.pour_beverage)
        private val volumeText: TextView = itemView.findViewById(R.id.pour_volume)
        private val timeText: TextView = itemView.findViewById(R.id.pour_time)

        fun bind(pour: Pour) {
            userText.text = pour.userName
            beverageText.text = pour.beverageName
            volumeText.text = "${pour.volumeOz} oz"
            timeText.text = pour.timeAgo
            // TODO: Load actual image with Glide or similar
            // For now, placeholder icon will show
        }
    }

    private class PourDiffCallback : DiffUtil.ItemCallback<Pour>() {
        override fun areItemsTheSame(oldItem: Pour, newItem: Pour): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Pour, newItem: Pour): Boolean {
            return oldItem == newItem
        }
    }
}

data class Pour(
    val id: Int,
    val userName: String,
    val beverageName: String,
    val volumeOz: Int,
    val timeAgo: String,
    val photoUrl: String? = null
)
